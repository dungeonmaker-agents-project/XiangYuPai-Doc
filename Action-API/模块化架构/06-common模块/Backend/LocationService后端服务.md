# LocationService 后端服务文档

## 服务概述

### 服务职责
LocationService是平台的地理位置服务,提供通用的位置服务能力,为全平台提供地点查询、位置解析、距离计算等功能。该服务被多个模块调用(内容同城、活动、附近用户等)。

### 技术栈
- **框架**: Spring Boot 3.2.0 + Spring Cloud 2023.0.3
- **ORM**: MyBatis-Plus 3.5.7
- **地图API**: 高德地图 API / 腾讯地图 API (备用)
- **缓存**: Redis 7.0+ (地点/城市/区域缓存)
- **数据库**: MySQL 8.0+ with SPATIAL INDEX
- **权限**: Sa-Token

### 服务信息
- **服务名**: xypai-location
- **服务端口**: 9407
- **所属模块**: 06-common模块
- **数据库**: xypai_location
- **RPC支持**: Dubbo 3.x (支持远程调用)

---

## 项目结构

```
xypai-location/
├── src/main/java/org/dromara/location/
│   ├── LocationApplication.java         # Spring Boot启动类
│   ├── controller/
│   │   ├── app/                         # C端API
│   │   │   ├── LocationController.java  # 位置查询API
│   │   │   ├── CityController.java      # 城市选择API
│   │   │   └── DistrictController.java  # 区域选择API
│   │   ├── admin/                       # B端管理API
│   │   │   ├── CityManageController.java
│   │   │   └── DistrictManageController.java
│   │   └── feign/                       # 内部RPC接口
│   │       └── RemoteLocationServiceImpl.java
│   ├── service/
│   │   ├── ILocationService.java        # 位置服务接口
│   │   ├── ICityService.java            # 城市服务接口
│   │   ├── IDistrictService.java        # 区域服务接口
│   │   ├── impl/
│   │   │   ├── LocationServiceImpl.java
│   │   │   ├── CityServiceImpl.java
│   │   │   └── DistrictServiceImpl.java
│   │   └── remote/
│   │       └── AmapApiService.java      # 高德地图API调用
│   ├── mapper/
│   │   ├── LocationMapper.java
│   │   ├── CityMapper.java
│   │   └── DistrictMapper.java
│   └── domain/
│       ├── entity/                      # 数据库实体
│       │   ├── Location.java
│       │   ├── City.java
│       │   └── District.java
│       ├── bo/                          # 业务对象(输入DTO)
│       │   ├── LocationQueryBo.java
│       │   ├── LocationAddBo.java
│       │   ├── CitySelectBo.java
│       │   └── DistrictSelectBo.java
│       └── vo/                          # 视图对象(输出DTO)
│           ├── LocationDetailVo.java
│           ├── LocationListVo.java
│           ├── CityListVo.java
│           ├── DistrictListVo.java
│           └── DistanceVo.java
├── src/main/resources/
│   ├── application.yml
│   ├── bootstrap.yml
│   └── mapper/location/
│       ├── LocationMapper.xml
│       ├── CityMapper.xml
│       └── DistrictMapper.xml
└── pom.xml
```

---

## API接口

### 对外API列表 (HTTP)

#### C端用户API

| 接口名称 | 方法 | 路径 | 描述 | 权限 |
|---------|------|------|------|------|
| 获取附近地点 | GET | `/api/location/nearby` | 查询附近POI | 需登录 |
| 搜索地点 | GET | `/api/location/search` | 关键词搜索地点 | 需登录 |
| GPS定位解析 | POST | `/api/location/geocode` | 地址→坐标 | 需登录 |
| 逆地理编码 | POST | `/api/location/regeocode` | 坐标→地址 | 需登录 |
| 获取城市列表 | GET | `/api/location/cities` | 获取所有城市 | 公开 |
| 选择城市 | POST | `/api/location/city/select` | 选择城市 | 需登录 |
| 获取区域列表 | GET | `/api/location/districts` | 获取城市区域 | 公开 |
| 选择区域 | POST | `/api/location/district/select` | 选择区域 | 需登录 |

#### B端管理API

| 接口名称 | 方法 | 路径 | 描述 | 权限 |
|---------|------|------|------|------|
| 城市管理列表 | GET | `/admin/location/city/list` | 分页查询城市 | admin:location:city:list |
| 添加城市 | POST | `/admin/location/city` | 添加城市 | admin:location:city:add |
| 更新城市 | PUT | `/admin/location/city` | 更新城市 | admin:location:city:edit |
| 删除城市 | DELETE | `/admin/location/city/{ids}` | 删除城市 | admin:location:city:remove |

### 内部RPC列表 (Dubbo)

| 接口名称 | 方法 | 调用方 | 功能 |
|---------|------|--------|------|
| calculateDistance() | POST | HomeService, ServiceService | 计算两点距离 |
| calculateBatchDistance() | POST | HomeService | 批量计算距离 |
| getCityInfo() | GET | 所有服务 | 获取城市详情 |
| getNearbyLocations() | GET | ContentService | 获取附近地点 |
| validateCoordinates() | POST | 所有服务 | 验证GPS坐标有效性 |

---

## 接口详细定义

### 接口1:获取附近地点

#### 请求定义
```
GET /api/location/nearby
```

#### 请求参数 (Query)
```java
@Data
public class NearbyLocationQuery {
    @NotNull(message = "纬度不能为空")
    @DecimalMin(value = "-90", message = "纬度必须在-90到90之间")
    @DecimalMax(value = "90", message = "纬度必须在-90到90之间")
    private BigDecimal latitude;    // 当前纬度

    @NotNull(message = "经度不能为空")
    @DecimalMin(value = "-180", message = "经度必须在-180到180之间")
    @DecimalMax(value = "180", message = "经度必须在-180到180之间")
    private BigDecimal longitude;   // 当前经度

    @Min(value = 1, message = "搜索半径最小为1km")
    @Max(value = 20, message = "搜索半径最大为20km")
    private Integer radius = 5;     // 搜索半径(km),默认5km

    private String category;        // 分类筛选(可选): 餐饮/商场/酒店等

    private Integer pageNum = 1;
    private Integer pageSize = 20;
}
```

#### 响应数据
```java
// Controller返回
public TableDataInfo<LocationListVo> getNearbyLocations(NearbyLocationQuery query) {
    return locationService.queryNearbyLocations(query);
}

// VO定义
@Data
@AutoMapper(target = Location.class)
public class LocationListVo implements Serializable {
    @Serial
    private static final long serialVersionUID = 1L;

    private Long id;                // 地点ID
    private String name;            // 地点名称
    private String address;         // 详细地址
    private BigDecimal latitude;    // 纬度
    private BigDecimal longitude;   // 经度
    private String category;        // 分类
    private BigDecimal distance;    // 距离(km)
    private String distanceText;    // 距离文本("1.2km")
}
```

#### 业务逻辑

**Service层实现**:
```java
@RequiredArgsConstructor
@Service
public class LocationServiceImpl implements ILocationService {

    private final LocationMapper baseMapper;
    private final RedisService redisService;

    @Override
    public TableDataInfo<LocationListVo> queryNearbyLocations(NearbyLocationQuery query) {
        // 1. 使用MySQL空间索引查询
        Page<Location> page = new Page<>(query.getPageNum(), query.getPageSize());

        // 2. 构建查询
        LambdaQueryWrapper<Location> wrapper = buildNearbyQueryWrapper(query);

        // 3. 执行查询
        Page<Location> result = baseMapper.selectNearbyPage(page, wrapper, query);

        // 4. 计算距离并转换为VO
        List<LocationListVo> voList = result.getRecords().stream()
            .map(location -> {
                LocationListVo vo = BeanUtil.toBean(location, LocationListVo.class);
                // 计算距离
                BigDecimal distance = calculateDistance(
                    query.getLatitude(), query.getLongitude(),
                    location.getLatitude(), location.getLongitude()
                );
                vo.setDistance(distance);
                vo.setDistanceText(formatDistance(distance));
                return vo;
            })
            .sorted(Comparator.comparing(LocationListVo::getDistance))
            .toList();

        // 5. 返回分页结果
        return TableDataInfo.build(voList, result.getTotal());
    }

    /**
     * Haversine公式计算球面距离
     */
    private BigDecimal calculateDistance(BigDecimal lat1, BigDecimal lon1,
                                        BigDecimal lat2, BigDecimal lon2) {
        final double R = 6371; // 地球半径(公里)

        double dLat = Math.toRadians(lat2.subtract(lat1).doubleValue());
        double dLon = Math.toRadians(lon2.subtract(lon1).doubleValue());

        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                   Math.cos(Math.toRadians(lat1.doubleValue())) *
                   Math.cos(Math.toRadians(lat2.doubleValue())) *
                   Math.sin(dLon / 2) * Math.sin(dLon / 2);

        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        double distance = R * c;

        return BigDecimal.valueOf(distance).setScale(2, RoundingMode.HALF_UP);
    }

    private String formatDistance(BigDecimal distance) {
        if (distance.compareTo(BigDecimal.valueOf(100)) > 0) {
            return ">100km";
        }
        return distance.toPlainString() + "km";
    }
}
```

**Mapper层实现**:
```java
public interface LocationMapper extends BaseMapperPlus<Location, LocationListVo> {

    /**
     * 查询附近地点(使用空间索引)
     */
    @Select("""
        SELECT *,
          ST_Distance_Sphere(
            location_point,
            ST_GeomFromText(CONCAT('POINT(', #{query.longitude}, ' ', #{query.latitude}, ')'), 4326)
          ) / 1000 AS distance
        FROM location
        WHERE ST_Distance_Sphere(
            location_point,
            ST_GeomFromText(CONCAT('POINT(', #{query.longitude}, ' ', #{query.latitude}, ')'), 4326)
          ) / 1000 <= #{query.radius}
          AND status = 0
          AND deleted = 0
          <if test="query.category != null and query.category != ''">
          AND category = #{query.category}
          </if>
        ORDER BY distance ASC
        LIMIT #{page.offset}, #{page.size}
    """)
    Page<Location> selectNearbyPage(@Param("page") Page<Location> page,
                                     @Param("ew") Wrapper<Location> wrapper,
                                     @Param("query") NearbyLocationQuery query);
}
```

#### 错误码
- 200: 成功
- 400: 参数错误(经纬度超范围)
- 401: 未登录
- 500: 服务器错误

---

### 接口2:搜索地点

#### 请求定义
```
GET /api/location/search
```

#### 请求参数
```java
@Data
public class LocationSearchQuery {
    @NotBlank(message = "搜索关键词不能为空")
    @Length(min = 1, max = 50, message = "关键词长度必须在1-50字符之间")
    private String keyword;         // 搜索关键词

    private BigDecimal latitude;    // 当前位置(用于排序)
    private BigDecimal longitude;

    private String cityCode;        // 城市限制(可选)

    private Integer pageNum = 1;
    private Integer pageSize = 20;
}
```

#### 响应数据
```java
public TableDataInfo<LocationListVo> searchLocations(LocationSearchQuery query) {
    return locationService.searchLocations(query);
}
```

#### 业务逻辑

**Service实现**:
```java
@Override
public TableDataInfo<LocationListVo> searchLocations(LocationSearchQuery query) {
    String cacheKey = "location:search:" + query.getKeyword() + ":" + query.getCityCode();

    // 1. 尝试从缓存获取
    List<LocationListVo> cached = redisService.getCacheObject(cacheKey);
    if (cached != null && !cached.isEmpty()) {
        return TableDataInfo.build(cached);
    }

    // 2. 数据库全文搜索
    Page<Location> page = new Page<>(query.getPageNum(), query.getPageSize());
    LambdaQueryWrapper<Location> wrapper = new LambdaQueryWrapper<>();
    wrapper.and(w -> w.like(Location::getName, query.getKeyword())
                      .or()
                      .like(Location::getAddress, query.getKeyword()))
           .eq(StringUtils.isNotBlank(query.getCityCode()), Location::getCityCode, query.getCityCode())
           .eq(Location::getDeleted, 0)
           .orderByDesc(Location::getCreatedAt);

    Page<Location> result = baseMapper.selectPage(page, wrapper);

    // 3. 转换为VO并计算距离
    List<LocationListVo> voList = result.getRecords().stream()
        .map(location -> {
            LocationListVo vo = BeanUtil.toBean(location, LocationListVo.class);
            if (query.getLatitude() != null && query.getLongitude() != null) {
                BigDecimal distance = calculateDistance(
                    query.getLatitude(), query.getLongitude(),
                    location.getLatitude(), location.getLongitude()
                );
                vo.setDistance(distance);
                vo.setDistanceText(formatDistance(distance));
            }
            return vo;
        })
        .toList();

    // 4. 缓存结果(5分钟)
    if (!voList.isEmpty()) {
        redisService.setCacheObject(cacheKey, voList, Duration.ofMinutes(5));
    }

    return TableDataInfo.build(voList, result.getTotal());
}
```

---

### 接口3:GPS定位解析(地理编码)

#### 请求定义
```
POST /api/location/geocode
Content-Type: application/json
```

#### 请求参数
```java
@Data
public class GeocodeBo {
    @NotBlank(message = "地址不能为空")
    @Length(max = 200, message = "地址长度不能超过200字符")
    private String address;     // 详细地址

    private String cityCode;    // 城市代码(可选,提高准确度)
}
```

#### 响应数据
```java
@Data
public class GeocodeVo implements Serializable {
    @Serial
    private static final long serialVersionUID = 1L;

    private BigDecimal latitude;        // 纬度
    private BigDecimal longitude;       // 经度
    private String formattedAddress;    // 格式化地址
    private String province;            // 省份
    private String city;                // 城市
    private String district;            // 区县
}
```

#### 业务逻辑

**Service实现**:
```java
@Override
public R<GeocodeVo> geocode(GeocodeBo bo) {
    try {
        // 调用高德地图地理编码API
        GeocodeVo result = amapApiService.geocode(bo.getAddress(), bo.getCityCode());
        return R.ok(result);
    } catch (Exception e) {
        log.error("地理编码失败", e);
        return R.fail("地址解析失败,请检查地址格式");
    }
}
```

**高德API调用**:
```java
@Service
@RequiredArgsConstructor
public class AmapApiService {

    @Value("${amap.api.key}")
    private String apiKey;

    public GeocodeVo geocode(String address, String cityCode) {
        String url = "https://restapi.amap.com/v3/geocode/geo";

        Map<String, String> params = new HashMap<>();
        params.put("key", apiKey);
        params.put("address", address);
        if (StringUtils.isNotBlank(cityCode)) {
            params.put("city", cityCode);
        }

        // HTTP调用(使用RestTemplate或HttpClient)
        String response = HttpUtil.get(url, params);
        JSONObject json = JSONUtil.parseObj(response);

        if (!"1".equals(json.getStr("status"))) {
            throw new ServiceException("高德地图API调用失败");
        }

        JSONArray geocodes = json.getJSONArray("geocodes");
        if (geocodes == null || geocodes.isEmpty()) {
            throw new ServiceException("地址解析失败");
        }

        JSONObject geocode = geocodes.getJSONObject(0);
        String location = geocode.getStr("location");
        String[] coords = location.split(",");

        GeocodeVo vo = new GeocodeVo();
        vo.setLongitude(new BigDecimal(coords[0]));
        vo.setLatitude(new BigDecimal(coords[1]));
        vo.setFormattedAddress(geocode.getStr("formatted_address"));
        vo.setProvince(geocode.getStr("province"));
        vo.setCity(geocode.getStr("city"));
        vo.setDistrict(geocode.getStr("district"));

        return vo;
    }
}
```

---

### 接口4:获取城市列表

#### 请求定义
```
GET /api/location/cities
```

#### 响应数据
```java
@Data
public class CityListResultVo implements Serializable {
    @Serial
    private static final long serialVersionUID = 1L;

    private CityInfoVo currentLocation;      // 当前定位城市
    private List<CityInfoVo> recentVisited;  // 最近访问城市(最多5个)
    private List<CityInfoVo> hotCities;      // 热门城市
    private List<CityGroupVo> allCities;     // 所有城市(按首字母分组)
}

@Data
public class CityInfoVo implements Serializable {
    private String cityCode;
    private String cityName;
    private String province;
    private LocalDateTime visitTime;  // 访问时间(仅recentVisited)
}

@Data
public class CityGroupVo implements Serializable {
    private String letter;            // 首字母 A-Z
    private List<CityInfoVo> cities;
}
```

#### 业务逻辑

**Service实现**:
```java
@Override
public R<CityListResultVo> getCityList(Long userId) {
    String cacheKey = "location:cities:all";

    // 1. 尝试缓存
    CityListResultVo cached = redisService.getCacheObject(cacheKey);
    if (cached != null) {
        // 个性化数据需要实时查询
        if (userId != null) {
            cached.setRecentVisited(getRecentVisitedCities(userId));
        }
        return R.ok(cached);
    }

    // 2. 查询所有城市
    LambdaQueryWrapper<City> wrapper = new LambdaQueryWrapper<>();
    wrapper.eq(City::getStatus, 1)
           .eq(City::getDeleted, 0)
           .orderByAsc(City::getPinyin);
    List<City> allCities = cityMapper.selectList(wrapper);

    // 3. 查询热门城市
    LambdaQueryWrapper<City> hotWrapper = new LambdaQueryWrapper<>();
    hotWrapper.eq(City::getIsHot, 1)
              .eq(City::getStatus, 1)
              .orderByAsc(City::getSortOrder);
    List<City> hotCities = cityMapper.selectList(hotWrapper);

    // 4. 按首字母分组
    Map<String, List<CityInfoVo>> groupedCities = allCities.stream()
        .map(city -> BeanUtil.toBean(city, CityInfoVo.class))
        .collect(Collectors.groupingBy(city ->
            city.getCityName().substring(0, 1).toUpperCase()));

    List<CityGroupVo> cityGroups = groupedCities.entrySet().stream()
        .map(entry -> {
            CityGroupVo group = new CityGroupVo();
            group.setLetter(entry.getKey());
            group.setCities(entry.getValue());
            return group;
        })
        .sorted(Comparator.comparing(CityGroupVo::getLetter))
        .toList();

    // 5. 构建结果
    CityListResultVo result = new CityListResultVo();
    result.setHotCities(BeanUtil.copyToList(hotCities, CityInfoVo.class));
    result.setAllCities(cityGroups);

    if (userId != null) {
        result.setRecentVisited(getRecentVisitedCities(userId));
    }

    // 6. 缓存24小时
    redisService.setCacheObject(cacheKey, result, Duration.ofHours(24));

    return R.ok(result);
}

private List<CityInfoVo> getRecentVisitedCities(Long userId) {
    // 从用户位置偏好表查询
    LambdaQueryWrapper<UserLocationPreference> wrapper = new LambdaQueryWrapper<>();
    wrapper.eq(UserLocationPreference::getUserId, userId)
           .orderByDesc(UserLocationPreference::getLastVisitTime)
           .last("LIMIT 5");

    List<UserLocationPreference> preferences = userLocationPreferenceMapper.selectList(wrapper);

    return preferences.stream()
        .map(pref -> {
            City city = cityMapper.selectOne(
                new LambdaQueryWrapper<City>()
                    .eq(City::getCityCode, pref.getCityCode())
            );
            CityInfoVo vo = BeanUtil.toBean(city, CityInfoVo.class);
            vo.setVisitTime(pref.getLastVisitTime());
            return vo;
        })
        .toList();
}
```

---

### RPC接口实现 (Dubbo)

#### API接口定义 (ruoyi-api-location)

```java
package org.dromara.location.api;

import org.dromara.common.core.domain.R;
import org.dromara.location.api.domain.DistanceVo;

/**
 * 位置服务远程调用接口
 */
public interface RemoteLocationService {

    /**
     * 计算两点距离
     */
    R<DistanceVo> calculateDistance(BigDecimal fromLat, BigDecimal fromLng,
                                    BigDecimal toLat, BigDecimal toLng);

    /**
     * 批量计算距离
     */
    R<List<DistanceVo>> calculateBatchDistance(BigDecimal fromLat, BigDecimal fromLng,
                                               List<LocationPointDto> targets);

    /**
     * 获取城市信息
     */
    R<CityInfoVo> getCityInfo(String cityCode);

    /**
     * 验证坐标有效性
     */
    R<Boolean> validateCoordinates(BigDecimal latitude, BigDecimal longitude);
}
```

#### RPC实现类

```java
package org.dromara.location.controller.feign;

import org.apache.dubbo.config.annotation.DubboService;
import org.dromara.location.api.RemoteLocationService;
import org.dromara.location.api.domain.DistanceVo;
import org.springframework.stereotype.Service;
import lombok.RequiredArgsConstructor;

/**
 * 位置服务远程调用实现
 */
@DubboService
@Service
@RequiredArgsConstructor
public class RemoteLocationServiceImpl implements RemoteLocationService {

    private final ILocationService locationService;
    private final ICityService cityService;

    @Override
    public R<DistanceVo> calculateDistance(BigDecimal fromLat, BigDecimal fromLng,
                                          BigDecimal toLat, BigDecimal toLng) {
        // 验证坐标
        if (!validateCoords(fromLat, fromLng) || !validateCoords(toLat, toLng)) {
            return R.fail("坐标参数无效");
        }

        // 计算距离
        BigDecimal distance = locationService.calculateDistance(fromLat, fromLng, toLat, toLng);

        DistanceVo vo = new DistanceVo();
        vo.setDistance(distance);
        vo.setUnit("km");
        vo.setDisplayText(distance.toPlainString() + "km");

        return R.ok(vo);
    }

    @Override
    public R<List<DistanceVo>> calculateBatchDistance(BigDecimal fromLat, BigDecimal fromLng,
                                                      List<LocationPointDto> targets) {
        if (targets == null || targets.isEmpty()) {
            return R.fail("目标坐标列表不能为空");
        }

        List<DistanceVo> distances = targets.stream()
            .map(target -> {
                BigDecimal distance = locationService.calculateDistance(
                    fromLat, fromLng, target.getLatitude(), target.getLongitude()
                );

                DistanceVo vo = new DistanceVo();
                vo.setId(target.getId());
                vo.setDistance(distance);
                vo.setDisplayText(distance.toPlainString() + "km");
                return vo;
            })
            .toList();

        return R.ok(distances);
    }

    @Override
    public R<CityInfoVo> getCityInfo(String cityCode) {
        CityInfoVo city = cityService.getByCityCode(cityCode);
        return city != null ? R.ok(city) : R.fail("城市不存在");
    }

    @Override
    public R<Boolean> validateCoordinates(BigDecimal latitude, BigDecimal longitude) {
        boolean valid = validateCoords(latitude, longitude);
        return R.ok(valid);
    }

    private boolean validateCoords(BigDecimal lat, BigDecimal lng) {
        if (lat == null || lng == null) {
            return false;
        }
        return lat.compareTo(BigDecimal.valueOf(-90)) >= 0 &&
               lat.compareTo(BigDecimal.valueOf(90)) <= 0 &&
               lng.compareTo(BigDecimal.valueOf(-180)) >= 0 &&
               lng.compareTo(BigDecimal.valueOf(180)) <= 0;
    }
}
```

#### 调用示例 (在HomeService中使用)

```java
@Service
@RequiredArgsConstructor
public class HomeFeedServiceImpl implements IHomeFeedService {

    @DubboReference  // Dubbo远程调用
    private RemoteLocationService remoteLocationService;

    @Override
    public List<FeedListVo> getNearbyFeeds(BigDecimal userLat, BigDecimal userLng) {
        // 查询附近动态
        List<Feed> feeds = feedMapper.selectNearbyFeeds(userLat, userLng, 5);

        // 批量计算距离
        List<LocationPointDto> points = feeds.stream()
            .map(feed -> new LocationPointDto(feed.getId(), feed.getLatitude(), feed.getLongitude()))
            .toList();

        R<List<DistanceVo>> distanceResult = remoteLocationService.calculateBatchDistance(
            userLat, userLng, points
        );

        if (!distanceResult.isSuccess()) {
            throw new ServiceException("距离计算失败");
        }

        // 组装结果
        Map<Long, BigDecimal> distanceMap = distanceResult.getData().stream()
            .collect(Collectors.toMap(DistanceVo::getId, DistanceVo::getDistance));

        return feeds.stream()
            .map(feed -> {
                FeedListVo vo = BeanUtil.toBean(feed, FeedListVo.class);
                vo.setDistance(distanceMap.get(feed.getId()));
                return vo;
            })
            .toList();
    }
}
```

---

## 数据模型

### Location (地点表)

```java
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("location")
public class Location extends BaseEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    @TableId(value = "id", type = IdType.ASSIGN_ID)
    private Long id;

    private String name;              // 地点名称
    private String address;           // 详细地址
    private BigDecimal latitude;      // 纬度
    private BigDecimal longitude;     // 经度
    private String geohash;           // Geohash编码(用于快速查询)

    private String category;          // 分类
    private String province;          // 省份
    private String cityCode;          // 城市代码
    private String city;              // 城市
    private String district;          // 区县
    private String street;            // 街道

    private String source;            // 数据来源: amap/baidu/user
    private String extraInfo;         // 额外信息(JSON)

    @TableField(value = "status")
    private Integer status;           // 0=正常,1=禁用

    @TableLogic
    @TableField(value = "deleted")
    private Long deleted;

    @Version
    @TableField(value = "version")
    private Long version;
}
```

**对应SQL**:
```sql
CREATE TABLE `location` (
    `id`            BIGINT(20)      NOT NULL COMMENT '地点ID',
    `name`          VARCHAR(100)    NOT NULL COMMENT '地点名称',
    `address`       VARCHAR(255)    NOT NULL COMMENT '详细地址',
    `latitude`      DECIMAL(10,6)   NOT NULL COMMENT '纬度',
    `longitude`     DECIMAL(10,6)   NOT NULL COMMENT '经度',
    `location_point` POINT          NOT NULL SRID 4326 COMMENT '地理坐标点(空间索引)',
    `geohash`       VARCHAR(20)     COMMENT 'Geohash编码',

    `category`      VARCHAR(50)     COMMENT '分类',
    `province`      VARCHAR(50)     COMMENT '省份',
    `city_code`     VARCHAR(10)     COMMENT '城市代码',
    `city`          VARCHAR(50)     COMMENT '城市',
    `district`      VARCHAR(50)     COMMENT '区县',
    `street`        VARCHAR(50)     COMMENT '街道',

    `source`        VARCHAR(20)     COMMENT '数据来源',
    `extra_info`    TEXT            COMMENT '额外信息JSON',

    `status`        TINYINT(1)      DEFAULT 0 COMMENT '状态',
    `created_at`    DATETIME        DEFAULT CURRENT_TIMESTAMP,
    `created_by`    BIGINT(20)      COMMENT '创建人',
    `updated_at`    DATETIME        DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `updated_by`    BIGINT(20)      COMMENT '更新人',
    `deleted`       BIGINT(20)      DEFAULT 0 COMMENT '逻辑删除',
    `version`       INT(11)         DEFAULT 0 COMMENT '乐观锁版本',

    PRIMARY KEY (`id`),
    SPATIAL KEY `idx_location_point` (`location_point`),
    KEY `idx_geohash` (`geohash`),
    KEY `idx_city_code` (`city_code`),
    KEY `idx_category` (`category`),
    FULLTEXT KEY `idx_fulltext` (`name`, `address`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='地点表';
```

### City (城市表)

```java
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("city")
public class City extends BaseEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    @TableId(value = "id", type = IdType.ASSIGN_ID)
    private Long id;

    private String cityCode;          // 城市代码
    private String cityName;          // 城市名称
    private String province;          // 省份
    private String pinyin;            // 拼音
    private String firstLetter;       // 首字母

    private BigDecimal centerLat;     // 中心点纬度
    private BigDecimal centerLng;     // 中心点经度

    private Integer isHot;            // 是否热门城市
    private Integer hasDistricts;     // 是否有区域划分
    private Integer sortOrder;        // 排序

    @TableField(value = "status")
    private Integer status;

    @TableLogic
    private Long deleted;

    @Version
    private Long version;
}
```

**对应SQL**:
```sql
CREATE TABLE `city` (
    `id`                BIGINT(20)      NOT NULL,
    `city_code`         VARCHAR(10)     UNIQUE NOT NULL COMMENT '城市代码',
    `city_name`         VARCHAR(50)     NOT NULL COMMENT '城市名称',
    `province`          VARCHAR(50)     COMMENT '省份',
    `pinyin`            VARCHAR(50)     COMMENT '拼音',
    `first_letter`      CHAR(1)         COMMENT '首字母',

    `center_lat`        DECIMAL(10,6)   COMMENT '中心点纬度',
    `center_lng`        DECIMAL(10,6)   COMMENT '中心点经度',
    `center_point`      POINT           SRID 4326 COMMENT '中心点坐标',
    `city_boundary`     POLYGON         COMMENT '城市边界多边形',

    `is_hot`            TINYINT(1)      DEFAULT 0 COMMENT '是否热门',
    `has_districts`     TINYINT(1)      DEFAULT 0 COMMENT '是否有区域',
    `sort_order`        INT(11)         DEFAULT 0 COMMENT '排序',

    `status`            TINYINT(1)      DEFAULT 1,
    `created_at`        DATETIME        DEFAULT CURRENT_TIMESTAMP,
    `created_by`        BIGINT(20),
    `updated_at`        DATETIME        DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `updated_by`        BIGINT(20),
    `deleted`           BIGINT(20)      DEFAULT 0,
    `version`           INT(11)         DEFAULT 0,

    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_city_code` (`city_code`),
    SPATIAL KEY `idx_center_point` (`center_point`),
    SPATIAL KEY `idx_city_boundary` (`city_boundary`),
    KEY `idx_first_letter` (`first_letter`),
    KEY `idx_is_hot` (`is_hot`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='城市表';
```

### District (区域表)

```java
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("district")
public class District extends BaseEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    @TableId(value = "id", type = IdType.ASSIGN_ID)
    private Long id;

    private String cityCode;          // 城市代码
    private String districtCode;      // 区域代码
    private String districtName;      // 区域名称

    private BigDecimal centerLat;     // 中心点纬度
    private BigDecimal centerLng;     // 中心点经度

    private Integer sortOrder;        // 排序

    @TableField(value = "status")
    private Integer status;

    @TableLogic
    private Long deleted;

    @Version
    private Long version;
}
```

**对应SQL**:
```sql
CREATE TABLE `district` (
    `id`                BIGINT(20)      NOT NULL,
    `city_code`         VARCHAR(10)     NOT NULL COMMENT '城市代码',
    `district_code`     VARCHAR(20)     UNIQUE NOT NULL COMMENT '区域代码',
    `district_name`     VARCHAR(50)     NOT NULL COMMENT '区域名称',

    `center_lat`        DECIMAL(10,6)   COMMENT '中心点纬度',
    `center_lng`        DECIMAL(10,6)   COMMENT '中心点经度',
    `center_point`      POINT           SRID 4326 COMMENT '中心点',
    `district_boundary` POLYGON         COMMENT '区域边界',

    `sort_order`        INT(11)         DEFAULT 0,

    `status`            TINYINT(1)      DEFAULT 1,
    `created_at`        DATETIME        DEFAULT CURRENT_TIMESTAMP,
    `created_by`        BIGINT(20),
    `updated_at`        DATETIME        DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `updated_by`        BIGINT(20),
    `deleted`           BIGINT(20)      DEFAULT 0,
    `version`           INT(11)         DEFAULT 0,

    PRIMARY KEY (`id`),
    KEY `idx_city_code` (`city_code`),
    SPATIAL KEY `idx_center_point` (`center_point`),
    SPATIAL KEY `idx_district_boundary` (`district_boundary`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='区域表';
```

### UserLocationPreference (用户位置偏好表)

```java
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("user_location_preference")
public class UserLocationPreference extends BaseEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    @TableId(value = "id", type = IdType.ASSIGN_ID)
    private Long id;

    private Long userId;              // 用户ID
    private String cityCode;          // 城市代码
    private String districtCode;      // 区域代码

    private BigDecimal lastLat;       // 最后定位纬度
    private BigDecimal lastLng;       // 最后定位经度

    private String selectSource;      // 选择来源: manual/gps
    private Integer visitCount;       // 访问次数
    private LocalDateTime lastVisitTime;  // 最后访问时间

    @TableLogic
    private Long deleted;

    @Version
    private Long version;
}
```

**对应SQL**:
```sql
CREATE TABLE `user_location_preference` (
    `id`                BIGINT(20)      NOT NULL,
    `user_id`           BIGINT(20)      NOT NULL COMMENT '用户ID',
    `city_code`         VARCHAR(10)     NOT NULL COMMENT '城市代码',
    `district_code`     VARCHAR(20)     COMMENT '区域代码',

    `last_lat`          DECIMAL(10,6)   COMMENT '最后定位纬度',
    `last_lng`          DECIMAL(10,6)   COMMENT '最后定位经度',
    `last_location`     POINT           SRID 4326 COMMENT '最后定位点',

    `select_source`     VARCHAR(20)     COMMENT '选择来源',
    `visit_count`       INT(11)         DEFAULT 1,
    `last_visit_time`   DATETIME        COMMENT '最后访问时间',

    `created_at`        DATETIME        DEFAULT CURRENT_TIMESTAMP,
    `updated_at`        DATETIME        DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted`           BIGINT(20)      DEFAULT 0,
    `version`           INT(11)         DEFAULT 0,

    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_user_city` (`user_id`, `city_code`, `deleted`),
    KEY `idx_user_id` (`user_id`),
    SPATIAL KEY `idx_last_location` (`last_location`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户位置偏好表';
```

---

## 性能优化

### 1. MySQL空间索引优化

**创建SPATIAL INDEX**:
```sql
ALTER TABLE location ADD SPATIAL INDEX idx_location_point(location_point);
```

**优化查询**:
```java
// 使用空间函数查询附近地点
@Select("""
    SELECT *,
      ST_Distance_Sphere(location_point, ST_GeomFromText(#{point}, 4326)) / 1000 AS distance
    FROM location
    WHERE MBRContains(
        ST_Buffer(ST_GeomFromText(#{point}, 4326), #{radiusMeters} / 111000),
        location_point
    )
    AND deleted = 0
    ORDER BY distance
    LIMIT #{limit}
""")
List<Location> findNearbyWithSpatialIndex(
    @Param("point") String point,
    @Param("radiusMeters") int radiusMeters,
    @Param("limit") int limit
);
```

### 2. Geohash索引优化

**使用Geohash快速过滤**:
```java
public List<Location> findNearbyWithGeohash(BigDecimal lat, BigDecimal lng, int radius) {
    // 1. 计算Geohash及邻居
    String centerHash = GeoHashUtil.encode(lat.doubleValue(), lng.doubleValue(), 6);
    List<String> neighbors = GeoHashUtil.getNeighbors(centerHash);
    List<String> searchHashes = new ArrayList<>(neighbors);
    searchHashes.add(centerHash);

    // 2. 使用IN查询快速过滤
    LambdaQueryWrapper<Location> wrapper = new LambdaQueryWrapper<>();
    wrapper.in(Location::getGeohash, searchHashes)
           .eq(Location::getDeleted, 0);

    List<Location> locations = baseMapper.selectList(wrapper);

    // 3. 精确计算距离并过滤
    return locations.stream()
        .map(loc -> {
            BigDecimal distance = calculateDistance(lat, lng, loc.getLatitude(), loc.getLongitude());
            loc.setDistance(distance);
            return loc;
        })
        .filter(loc -> loc.getDistance().doubleValue() <= radius)
        .sorted(Comparator.comparing(Location::getDistance))
        .toList();
}
```

### 3. Redis缓存策略

**城市列表缓存**:
```java
// Key: location:cities:all
// TTL: 24小时
public CityListResultVo getCityListWithCache() {
    String cacheKey = "location:cities:all";
    CityListResultVo cached = redisService.getCacheObject(cacheKey);

    if (cached != null) {
        return cached;
    }

    CityListResultVo result = buildCityList();
    redisService.setCacheObject(cacheKey, result, Duration.ofHours(24));

    return result;
}
```

**搜索结果缓存**:
```java
// Key: location:search:{keyword}:{cityCode}
// TTL: 5分钟
public List<LocationListVo> searchWithCache(String keyword, String cityCode) {
    String cacheKey = "location:search:" + keyword + ":" + cityCode;
    List<LocationListVo> cached = redisService.getCacheObject(cacheKey);

    if (cached != null) {
        return cached;
    }

    List<LocationListVo> result = performSearch(keyword, cityCode);
    redisService.setCacheObject(cacheKey, result, Duration.ofMinutes(5));

    return result;
}
```

**热门地点缓存**:
```java
// Key: location:hot:{cityCode}
// TTL: 1小时
public List<LocationListVo> getHotLocations(String cityCode) {
    String cacheKey = "location:hot:" + cityCode;
    List<LocationListVo> cached = redisService.getCacheObject(cacheKey);

    if (cached != null) {
        return cached;
    }

    // 查询访问量最高的地点
    LambdaQueryWrapper<Location> wrapper = new LambdaQueryWrapper<>();
    wrapper.eq(Location::getCityCode, cityCode)
           .eq(Location::getDeleted, 0)
           .orderByDesc(Location::getViewCount)
           .last("LIMIT 20");

    List<Location> hotLocations = baseMapper.selectList(wrapper);
    List<LocationListVo> result = BeanUtil.copyToList(hotLocations, LocationListVo.class);

    redisService.setCacheObject(cacheKey, result, Duration.ofHours(1));

    return result;
}
```

---

## 监控与日志

### 日志配置

**Logback配置** (logback-plus.xml):
```xml
<logger name="org.dromara.location" level="INFO" additivity="false">
    <appender-ref ref="file_info"/>
    <appender-ref ref="STDOUT"/>
</logger>

<!-- SQL日志(开发环境) -->
<logger name="org.dromara.location.mapper" level="DEBUG" additivity="false">
    <appender-ref ref="STDOUT"/>
</logger>
```

### 业务日志

**Controller层日志**:
```java
@Log(title = "位置服务", businessType = BusinessType.SELECT)
@GetMapping("/nearby")
public TableDataInfo<LocationListVo> getNearbyLocations(NearbyLocationQuery query) {
    log.info("查询附近地点: lat={}, lng={}, radius={}",
        query.getLatitude(), query.getLongitude(), query.getRadius());

    return locationService.queryNearbyLocations(query);
}
```

**Service层日志**:
```java
@Override
public TableDataInfo<LocationListVo> queryNearbyLocations(NearbyLocationQuery query) {
    long startTime = System.currentTimeMillis();

    try {
        TableDataInfo<LocationListVo> result = performQuery(query);

        long elapsed = System.currentTimeMillis() - startTime;
        log.info("附近地点查询完成: total={}, elapsed={}ms", result.getTotal(), elapsed);

        return result;
    } catch (Exception e) {
        log.error("附近地点查询失败: {}", e.getMessage(), e);
        throw new ServiceException("查询失败");
    }
}
```

### 监控指标

**关键指标**:
- 定位成功率: > 95%
- 距离计算准确率: 100%
- 平均响应时间: < 100ms
- 缓存命中率: > 80%
- 高德API可用性: > 99%

**告警规则**:
1. 定位失败率 > 5% - P2级别
2. 高德API超时 > 1s - P2级别
3. 距离计算异常 - P1级别
4. 服务不可用 - P0级别

---

## 配置管理

### application.yml

```yaml
server:
  port: 9407

spring:
  application:
    name: xypai-location
  profiles:
    active: @profiles.active@
```

### bootstrap.yml

```yaml
spring:
  application:
    name: xypai-location
  cloud:
    nacos:
      server-addr: @nacos.server@
      discovery:
        namespace: @nacos.namespace@
        group: @nacos.discovery.group@
      config:
        namespace: @nacos.namespace@
        group: @nacos.config.group@
        file-extension: yml
  config:
    import:
      - optional:nacos:application-common.yml
      - optional:nacos:datasource.yml
      - optional:nacos:xypai-location-${spring.profiles.active}.yml
```

### Nacos配置 (xypai-location-dev.yml)

```yaml
# 数据库配置
spring:
  datasource:
    dynamic:
      primary: master
      datasource:
        master:
          type: ${spring.datasource.type}
          driver-class-name: com.mysql.cj.jdbc.Driver
          url: jdbc:mysql://${datasource.host}:${datasource.port}/xypai_location?useSSL=false&serverTimezone=Asia/Shanghai&characterEncoding=utf8mb4

# 高德地图配置
amap:
  api:
    key: your_amap_api_key_here
    timeout: 5000

# 位置服务配置
location:
  default:
    search-radius: 5          # 默认搜索半径(km)
    max-radius: 20            # 最大搜索半径(km)
    page-size: 20             # 默认分页大小
  cache:
    city-list-ttl: 86400      # 城市列表缓存(秒)
    search-result-ttl: 300    # 搜索结果缓存(秒)
    hot-location-ttl: 3600    # 热门地点缓存(秒)
```

---

## POM依赖

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0">
    <parent>
        <groupId>org.dromara</groupId>
        <artifactId>ruoyi-cloud-plus</artifactId>
        <version>${revision}</version>
    </parent>
    <modelVersion>4.0.0</modelVersion>

    <artifactId>xypai-location</artifactId>

    <dependencies>
        <!-- 核心依赖 -->
        <dependency>
            <groupId>org.dromara</groupId>
            <artifactId>ruoyi-common-nacos</artifactId>
        </dependency>
        <dependency>
            <groupId>org.dromara</groupId>
            <artifactId>ruoyi-common-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.dromara</groupId>
            <artifactId>ruoyi-common-mybatis</artifactId>
        </dependency>

        <!-- 安全认证 -->
        <dependency>
            <groupId>org.dromara</groupId>
            <artifactId>ruoyi-common-security</artifactId>
        </dependency>

        <!-- 缓存 -->
        <dependency>
            <groupId>org.dromara</groupId>
            <artifactId>ruoyi-common-redis</artifactId>
        </dependency>

        <!-- RPC -->
        <dependency>
            <groupId>org.dromara</groupId>
            <artifactId>ruoyi-common-dubbo</artifactId>
        </dependency>

        <!-- API文档 -->
        <dependency>
            <groupId>org.dromara</groupId>
            <artifactId>ruoyi-common-doc</artifactId>
        </dependency>

        <!-- 日志 -->
        <dependency>
            <groupId>org.dromara</groupId>
            <artifactId>ruoyi-common-log</artifactId>
        </dependency>

        <!-- API接口 -->
        <dependency>
            <groupId>org.dromara</groupId>
            <artifactId>ruoyi-api-location</artifactId>
        </dependency>

        <!-- HTTP客户端 -->
        <dependency>
            <groupId>cn.hutool</groupId>
            <artifactId>hutool-http</artifactId>
        </dependency>
    </dependencies>
</project>
```

---

## 测试用例

### 单元测试

```java
@SpringBootTest
@RunWith(SpringRunner.class)
public class LocationServiceTest {

    @Autowired
    private ILocationService locationService;

    @Test
    public void testCalculateDistance() {
        BigDecimal distance = locationService.calculateDistance(
            BigDecimal.valueOf(22.5331), BigDecimal.valueOf(113.9385),
            BigDecimal.valueOf(22.5431), BigDecimal.valueOf(113.9485)
        );

        Assert.assertNotNull(distance);
        Assert.assertTrue(distance.doubleValue() > 0);
        Assert.assertTrue(distance.doubleValue() < 100);
    }

    @Test
    public void testNearbyQuery() {
        NearbyLocationQuery query = new NearbyLocationQuery();
        query.setLatitude(BigDecimal.valueOf(22.5331));
        query.setLongitude(BigDecimal.valueOf(113.9385));
        query.setRadius(5);
        query.setPageNum(1);
        query.setPageSize(20);

        TableDataInfo<LocationListVo> result = locationService.queryNearbyLocations(query);

        Assert.assertNotNull(result);
        Assert.assertNotNull(result.getRows());
    }
}
```

### 性能测试

- [ ] 附近地点查询 < 100ms (P95)
- [ ] 距离计算 < 20ms (P95)
- [ ] GPS定位 < 200ms (P95,依赖外部API)
- [ ] 城市列表查询 < 50ms (P95,缓存)
- [ ] 并发200 QPS稳定

---

## 部署说明

### Docker部署

```dockerfile
FROM openjdk:21-jdk-slim

WORKDIR /app

COPY target/xypai-location.jar app.jar

EXPOSE 9407

ENV JAVA_OPTS="-Xms512m -Xmx1024m"

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
```

### 启动命令

```bash
java -jar xypai-location.jar \
  --spring.profiles.active=prod \
  --server.port=9407
```

---

## 版本历史

| 版本 | 日期 | 说明 | 负责人 |
|------|------|------|--------|
| 1.0.0 | 2025-11-XX | 初始版本,基础位置服务功能 | XiangYuPai Team |
| 1.1.0 | 待定 | 增加百度地图API支持 | - |
| 1.2.0 | 待定 | 增加路径规划功能 | - |

---

**文档版本:** v1.0
**创建日期:** 2025-11-14
**所属模块:** 06-common模块
**技术栈:** Spring Boot 3.2.0 + MyBatis-Plus 3.5.7 + RuoYi-Cloud-Plus
**维护团队:** 基础服务团队
