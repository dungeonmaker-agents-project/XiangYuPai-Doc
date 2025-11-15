# 06-common模块 (基础设施)

## 模块概述

**模块职责**: 文件上传、位置服务、配置管理、通用工具

这是应用的**基础设施模块**,提供所有模块共享的通用功能,是整个系统的基础支撑。

---

## 后端服务 (2个)

### CommonService (通用服务)
- **文档**: [Backend/通用服务接口文档.md](./Backend/通用服务接口文档.md)
- **职责**: 文件上传、图片处理、配置管理
- **端口**: 8901
- **API路径**: `/api/common/*`
- **接口数**: 6个
- **对外API**: 3个
- **RPC接口**: 3个

**主要功能**:
- 图片上传(OSS)
- 图片压缩与处理
- 系统配置管理
- 文件访问权限控制

**RPC接口**:
- `uploadImage()` - 上传图片
- `getConfig()` - 获取配置
- `validateFile()` - 验证文件

### LocationService (位置服务)
- **文档**: [Backend/位置服务接口文档.md](./Backend/位置服务接口文档.md)
- **职责**: 城市定位、距离计算、区域管理
- **端口**: 8902
- **API路径**: `/api/location/*`
- **接口数**: 9个
- **对外API**: 5个
- **RPC接口**: 4个

**主要功能**:
- 城市列表与区域列表
- GPS定位与地理编码
- 距离计算(两点间距离)
- IP定位

**RPC接口**:
- `getDistance()` - 计算两点距离
- `getCityInfo()` - 获取城市信息
- `getDistrictInfo()` - 获取区域信息
- `reverseGeocode()` - 坐标反解析

---

## 前端页面 (2个) ✅

1. [03-区域选择页面.md](./Frontend/03-区域选择页面.md)
   - 路由: `/location/district`
   - 功能: 选择区域(南山区、福田区等)
   - 接口: `GET /api/location/districts`, `POST /api/location/select/district`

2. [04-城市定位页面.md](./Frontend/04-城市定位页面.md)
   - 路由: `/location/city`
   - 功能: 城市列表、GPS定位、热门城市
   - 接口: `GET /api/location/cities`, `POST /api/location/detect`, `POST /api/location/select/city`

---

## 服务依赖关系

### CommonService 依赖

```
CommonService
  → Aliyun OSS (对象存储)
  → (可选) CDN (加速访问)
```

### LocationService 依赖

```
LocationService
  → 高德地图API (地理编码、逆地理编码)
  → (可选) 百度地图API (备用)
  → IP定位服务
```

### 被依赖的服务 (基础设施)

```
CommonService 被调用:
  ← ActivityService.publish() (上传活动图片)
  ← UserService.updateAvatar() (上传头像)
  ← ServiceService.publish() (上传服务图片)
  ← (所有需要上传图片的服务)

LocationService 被调用:
  ← HomeService.getFeed() (计算用户距离)
  ← SearchService.search() (搜索附近的人)
  ← ActivityService.getList() (计算活动距离)
  ← ServiceService.getList() (计算服务距离)
  ← (所有需要位置信息的服务)
```

---

## 数据库设计

**数据库名**: `infra_db`

**主要表结构**:
```sql
-- 城市表
cities
  - city_code (城市代码,主键)
  - city_name (城市名称)
  - province_name (省份名称)
  - latitude (纬度)
  - longitude (经度)
  - is_hot (是否热门城市)
  - sort_order (排序)

-- 区域表
districts
  - district_code (区域代码,主键)
  - district_name (区域名称)
  - city_code (所属城市)
  - latitude (纬度)
  - longitude (经度)
  - boundary (边界坐标,GeoJSON)

-- 文件记录表
files
  - file_id (文件ID)
  - file_name (文件名)
  - file_path (OSS路径)
  - file_type (image/video/doc)
  - file_size (文件大小,字节)
  - uploader_id (上传者ID)
  - upload_time (上传时间)
  - access_url (访问URL)
  - is_public (是否公开)

-- 系统配置表
system_configs
  - config_key (配置键)
  - config_value (配置值)
  - config_type (string/int/json)
  - description (描述)
  - updated_at
```

---

## 技术栈

### 后端
- **框架**: Spring Boot 3.x
- **ORM**: MyBatis-Plus
- **缓存**: Redis (位置信息缓存,城市列表缓存)
- **对象存储**: Aliyun OSS
- **地图服务**: 高德地图API

### 第三方集成
- **OSS**: Aliyun OSS SDK
- **地图**: 高德地图 Web服务API
- **图片处理**: ImageMagick / Thumbnailator

---

## CommonService详解

### 图片上传流程

```
前端
  ↓
POST /api/common/upload/image
  ↓
CommonService
  1. 验证文件格式(jpg/png/gif)
  2. 验证文件大小(<5MB)
  3. 生成唯一文件名
  4. 上传到OSS
  5. 生成缩略图(可选)
  6. 返回访问URL
```

### 支持的图片格式
- JPG/JPEG
- PNG
- GIF
- WebP

### 图片处理
- 压缩(自动压缩>1MB的图片)
- 缩略图生成(100x100, 200x200, 400x400)
- 水印添加(可选)

### 文件命名规则
```
{userId}/{module}/{timestamp}_{random}.{ext}
示例: 123456/activity/1699876543210_abc123.jpg
```

---

## LocationService详解

### 距离计算算法

使用**Haversine公式**计算两点球面距离:

```java
/**
 * 计算两点间距离(单位:公里)
 * @param lat1 纬度1
 * @param lon1 经度1
 * @param lat2 纬度2
 * @param lon2 经度2
 * @return 距离(km)
 */
public Double getDistance(Double lat1, Double lon1, Double lat2, Double lon2) {
    final int R = 6371; // 地球半径(km)

    double latDistance = Math.toRadians(lat2 - lat1);
    double lonDistance = Math.toRadians(lon2 - lon1);

    double a = Math.sin(latDistance / 2) * Math.sin(latDistance / 2)
            + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
            * Math.sin(lonDistance / 2) * Math.sin(lonDistance / 2);

    double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
}
```

### 定位方式
1. **GPS定位** (精度高,需要用户授权)
2. **IP定位** (精度低,自动定位)
3. **手动选择** (用户主动选择城市/区域)

### 缓存策略
```
城市列表:
  - Key: location:cities
  - TTL: 永久(很少变化)
  - 更新策略: 手动更新

区域列表:
  - Key: location:districts:{cityCode}
  - TTL: 永久
  - 更新策略: 手动更新

用户位置:
  - Key: location:user:{userId}
  - TTL: 24小时
  - 更新策略: 用户选择位置时更新
```

---

## API映射表

### 前端页面使用

| 前端页面 | 主要API | 后端服务 |
|---------|---------|---------|
| 03-区域选择 | GET /api/location/districts | LocationService |
| 04-城市定位 | GET /api/location/cities | LocationService |
|  | POST /api/location/detect | LocationService |

### 其他页面使用的CommonService接口

| 页面 | 接口 | 用途 |
|------|------|------|
| 10-发布组局 | POST /api/common/upload/image | 上传活动图片 |
| 02-编辑资料 (待建) | POST /api/common/upload/image | 上传头像 |

### RPC调用

| 调用方 | 接口 | 用途 |
|--------|------|------|
| HomeService | LocationService.getDistance() | 计算用户距离 |
| SearchService | LocationService.getCityInfo() | 获取城市信息 |
| ActivityService | CommonService.uploadImage() | 上传图片 |

---

## RPC接口清单

### CommonService提供

```java
/**
 * 上传图片(RPC调用)
 * @param imageData 图片数据(Base64或字节流)
 * @param userId 上传者ID
 * @param module 模块名称(activity/user/service)
 * @return 图片访问URL
 */
String uploadImage(byte[] imageData, Long userId, String module);

/**
 * 获取配置
 * @param configKey 配置键
 * @return 配置值
 */
String getConfig(String configKey);

/**
 * 验证文件
 * @param fileUrl 文件URL
 * @return 是否有效
 */
Boolean validateFile(String fileUrl);
```

### LocationService提供

```java
/**
 * 计算两点距离
 * @param lat1 纬度1
 * @param lon1 经度1
 * @param lat2 纬度2
 * @param lon2 经度2
 * @return 距离(km)
 */
Double getDistance(Double lat1, Double lon1, Double lat2, Double lon2);

/**
 * 批量计算距离
 * @param origin 原点坐标
 * @param targets 目标坐标列表
 * @return Map<targetId, distance>
 */
Map<Long, Double> batchGetDistance(Location origin, List<Location> targets);

/**
 * 获取城市信息
 * @param cityCode 城市代码
 * @return CityInfo
 */
CityInfo getCityInfo(String cityCode);

/**
 * 坐标反解析
 * @param latitude 纬度
 * @param longitude 经度
 * @return 地址信息(省、市、区)
 */
AddressInfo reverseGeocode(Double latitude, Double longitude);
```

---

## 测试要点

### CommonService测试
- [ ] 图片上传成功
- [ ] 文件格式验证正确
- [ ] 文件大小限制有效
- [ ] 缩略图生成正常
- [ ] OSS访问URL可用

### LocationService测试
- [ ] 城市列表完整准确
- [ ] 区域列表正确
- [ ] 距离计算精确
- [ ] GPS定位功能正常
- [ ] IP定位可用

### 性能测试
- [ ] 图片上传响应时间 < 2s
- [ ] 距离计算响应时间 < 50ms
- [ ] 城市列表缓存命中率 > 99%

---

## 性能优化

### 图片上传优化
```java
// 异步上传到OSS
@Async
public CompletableFuture<String> uploadImageAsync(byte[] imageData) {
    // 1. 压缩图片
    byte[] compressed = compressImage(imageData);

    // 2. 上传OSS
    String url = ossClient.putObject(compressed);

    // 3. 异步生成缩略图
    generateThumbnails(url);

    return CompletableFuture.completedFuture(url);
}
```

### 距离计算优化
```java
// 批量计算距离,避免N次RPC调用
public Map<Long, Double> batchCalculateDistance(
    Location origin,
    List<Location> targets
) {
    return targets.stream()
        .collect(Collectors.toMap(
            Location::getId,
            target -> getDistance(origin, target)
        ));
}
```

---

## 监控告警

### 关键指标
- 图片上传成功率
- OSS存储容量
- 距离计算RPC调用量
- 第三方地图API调用量

### 告警规则
- 图片上传失败率 > 1% → P2告警
- OSS存储使用率 > 80% → P1告警
- 地图API调用失败率 > 5% → P2告警

---

## 下一步计划

### Phase 1: 功能增强
- [ ] 支持视频上传
- [ ] 添加文件CDN加速
- [ ] 完善地理围栏功能

### Phase 2: 性能优化
- [ ] 图片上传并发优化
- [ ] 距离计算缓存优化
- [ ] OSS访问优化

---

**⚠️ 重要提示**:
Common模块是所有服务的基础依赖,任何变更必须充分测试,避免影响整个系统。OSS密钥等敏感配置需要加密存储。

**模块维护者**: 基础设施团队
**最后更新**: 2025-11-14
