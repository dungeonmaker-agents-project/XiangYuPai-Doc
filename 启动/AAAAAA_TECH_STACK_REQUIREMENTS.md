# 🏗️ XY相遇派项目技术栈规范（技术宪章）

> **适用对象**: 全体开发人员（10人团队）  
> **强制等级**: MANDATORY  
> **版本**: v1.1 (数据分析增强版)  
> **更新日期**: 2025-10-13

**📌 本文档整合以下内容**:
- ✅ 核心技术栈规范
- ✅ 架构模式与编码规范
- ✅ v7.1数据库优化方案
- ✅ 10人团队实施指南
- ✅ 8个ADR架构决策
- ✅ 性能优化策略

**📖 阅读时间**: 30分钟  
**📋 页数**: 约35页（精简版）

---

## 📑 目录

1. [核心技术栈](#核心技术栈版本锁定)
2. [架构模式](#架构模式强制遵循)
3. [编码规范](#编码规范核心约束)
4. [数据库规范](#数据库规范)
5. [v7.1数据库优化](#v71数据库优化核心)
6. [安全规范](#安全规范)
7. [性能规范](#性能规范)
8. [API规范](#api规范)
9. [测试规范](#测试规范)
10. [ADR架构决策](#adr架构决策8个)
11. [10人团队实施](#10人团队实施指南)
12. [开发检查清单](#开发检查清单)
13. [禁止清单](#禁止清单零容忍)
14. [核心原则](#核心原则记住这5条)

---

## 📦 核心技术栈（版本锁定）

### 后端技术栈
```yaml
语言运行时:
  - Java: 21 (LTS)

核心框架:
  - Spring Boot: 3.2.0
  - Spring Cloud: 2023.0.3
  - Spring Cloud Alibaba: 2023.0.1.2

数据访问:
  - MyBatis Plus: 3.5.7 (优先使用LambdaQueryWrapper)
  - Druid: 1.2.23 (连接池)
  - MySQL Connector: 8.0+

微服务组件:
  - Nacos: 2.x (注册中心 + 配置中心)
  - Sentinel: (限流熔断)
  - Gateway: (API网关)
  - OpenFeign: (服务调用)

中间件:
  - MySQL: 8.0+ (主数据库)
  - Redis: 7.0+ (缓存 + 统计)
  - RabbitMQ/Kafka: (消息队列)

工具库:
  - Lombok: 1.18.30
  - FastJSON2: 2.0.57
  - JWT: 0.9.1
  - Knife4j: 4.4.0 (OpenAPI 3.0)
```

### 前端技术栈
```yaml
框架:
  - Vue.js: 3.x
  - Element Plus: (UI组件)
  - Pinia: (状态管理)
  - Vue Router: 4.x

工具:
  - Axios: (HTTP客户端)
  - Vite/Webpack: (构建工具)
```

---

## 🏛️ 架构模式（强制遵循）

### 1. 微服务架构规范
```
微服务边界:
  ✅ 每个服务独立数据库
  ✅ 服务间通过Feign调用
  ✅ 使用@InnerAuth保护内部接口
  ❌ 禁止跨服务直连数据库
  ❌ 禁止服务间循环依赖

端口分配规则:
  - Gateway: 8080
  - Auth: 8081
  - User: 9401
  - Content: 9402
  - Trade: 9403
  - Chat: 9404
  - File: 9405
  - (新增服务从9406开始)
```

### 2. 分层架构规范
```
强制四层架构:
  Controller层  → 接收请求、参数校验、响应封装
    ├─ admin/   → 管理端接口
    ├─ app/     → 用户端接口
    └─ feign/   → 内部调用接口

  Service层     → 业务逻辑、事务管理
    ├─ interface → 接口定义
    ├─ impl/     → 实现类
    └─ remote/   → 远程调用

  Mapper层      → 数据访问（优先MyBatis Plus，少写XML）
  
  Domain层      → 数据模型
    ├─ entity/  → 数据库实体（@TableName）
    ├─ dto/     → 请求对象（AddDTO/UpdateDTO/QueryDTO）
    ├─ vo/      → 响应对象（DetailVO/ListVO）
    └─ bo/      → 业务对象（可选）

禁止:
  ❌ Controller直接调用Mapper
  ❌ Entity包含业务逻辑
  ❌ 跨层调用
```

### 3. 公共模块集成
```
强制使用xypai-common模块:
  - xypai-common-core       → 工具类、BaseEntity、R<T>
  - xypai-common-security   → @RequiresPermissions、SecurityUtils
  - xypai-common-redis      → RedisService
  - xypai-common-log        → @Log注解
  - xypai-common-swagger    → API文档
  - xypai-common-datascope  → @DataScope数据权限
  - xypai-common-sensitive  → @Sensitive脱敏
```

---

## 💻 编码规范（核心约束）

### 1. 实体设计
```java
强制要求:
  ✅ 继承BaseEntity（获得created_at/updated_at）
  ✅ 使用@TableName指定表名
  ✅ 使用@TableId(type = IdType.ASSIGN_ID) 雪花ID
  ✅ 使用@Builder模式
  ✅ 软删除使用@TableLogic + deleted字段
  ✅ 乐观锁使用@Version + version字段

示例:
@Data
@Builder
@TableName("user")
public class User implements Serializable {
    @TableId(type = IdType.ASSIGN_ID)
    private Long id;
    
    @TableLogic
    @Builder.Default
    private Boolean deleted = false;
    
    @Version
    @Builder.Default
    private Integer version = 0;
}
```

### 2. DTO/VO设计
```java
强制要求:
  ✅ 使用@Builder + @Data
  ✅ 使用Jakarta Validation注解
  ✅ DTO命名: {Entity}AddDTO、{Entity}UpdateDTO、{Entity}QueryDTO
  ✅ VO命名: {Entity}DetailVO、{Entity}ListVO

示例:
@Data
@Builder
public class UserAddDTO implements Serializable {
    @NotBlank(message = "手机号不能为空")
    @Pattern(regexp = "^1[3-9]\\d{9}$")
    private String mobile;
}
```

### 3. Controller设计
```java
强制要求:
  ✅ 继承BaseController
  ✅ 使用@Tag、@Operation注解（Swagger）
  ✅ 使用@RequiresPermissions鉴权
  ✅ 使用@Log记录操作
  ✅ 返回R<T>或TableDataInfo
  ✅ 使用@Validated校验

示例:
@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
public class UserController extends BaseController {
    
    @GetMapping("/{id}")
    @RequiresPermissions("user:user:query")
    @Log(title = "查询用户", businessType = BusinessType.QUERY)
    public R<UserDetailVO> getInfo(@PathVariable Long id) {
        return R.ok(userService.getInfo(id));
    }
}
```

### 4. Service设计
```java
强制要求:
  ✅ 接口定义: I{Entity}Service
  ✅ 实现类: {Entity}ServiceImpl
  ✅ 使用@RequiredArgsConstructor注入
  ✅ 事务使用@Transactional(rollbackFor = Exception.class)
  ✅ 使用LambdaQueryWrapper构建查询
  ✅ 异常使用ServiceException

禁止:
  ❌ 方法超过20行
  ❌ catch Exception不处理
  ❌ 返回null（使用Optional）
```

---

## 🗄️ 数据库规范

### 1. 表设计规范
```sql
必须字段:
  - id BIGINT PRIMARY KEY AUTO_INCREMENT
  - created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  - updated_at DATETIME ON UPDATE CURRENT_TIMESTAMP
  - deleted TINYINT DEFAULT 0 (软删除)
  - version INT DEFAULT 0 (乐观锁)

命名规范:
  - 表名: 小写+下划线 (user_profile)
  - 字段: 小写+下划线 (created_at)
  - 索引: idx_前缀 (idx_user_status)
  - 唯一索引: uk_前缀 (uk_mobile)
```

### 2. 索引规范
```sql
强制要求:
  ✅ WHERE条件字段建索引
  ✅ 外键字段建索引
  ✅ 排序字段建索引
  ❌ 单表索引不超过5个
  ❌ 禁止SELECT *
```

### 3. 迁移方案（MVP → 生产）
```
当前架构 (11张表):
  - 使用JSON存储灵活数据
  - metadata字段存储扩展信息

目标架构 (60张表):
  - 字段完全展开
  - 统计数据分离 (UserStats/ContentStats)
  - 空间索引优化 (POINT类型)
  - 消息分片 (256张表)

升级策略:
  ✅ 双写策略（新旧字段并存）
  ✅ 灰度切换（5%→20%→50%→100%）
  ✅ 数据校验（定时任务修正）
```

---

## 🆕 v7.1数据库优化（核心）

> **更新日期**: 2025-10-13  
> **优化范围**: 用户行为分析体系  
> **影响表数**: 5张表增强114个字段

### v7.1优化总览

| 表名 | 原字段 | 新字段 | 增加 | 核心优化 |
|------|--------|--------|------|---------|
| UserBehavior | 8 | 24 | +16 | 会话追踪+转化分析+分区表 ⭐ |
| SearchHistory | 5 | 15 | +10 | 点击分析+满意度判断 |
| HotSearch | 8 | 23 | +15 | 趋势分析+排名系统 |
| UserPreference | 13 | 28 | +15 | 筛选+通知+隐私一体化 |
| City | 9 | 24 | +15 | POLYGON边界+空间索引 ⭐ |

### 核心新增字段

**UserBehavior（行为追踪）**:
```sql
session_id           -- 会话ID（关联单次访问）
scroll_depth         -- 滚动深度（内容吸引力）
is_conversion        -- 是否转化（漏斗分析）
conversion_value     -- 转化价值（订单金额）
date_partition       -- 分区键（性能优化）⭐
```

**SearchHistory（搜索分析）**:
```sql
keyword_normalized   -- 标准化关键词（去重）
first_click_position -- 首次点击位置（排序质量）
is_satisfied         -- 是否满意（智能判断）
date_partition       -- 分区键 ⭐
```

**HotSearch（热搜榜单）**:
```sql
trend_score          -- 趋势分数（识别爆发词）
rank_position        -- 当前排名（1-50）
rank_change          -- 排名变化（↑↓）
is_rising            -- 是否上升（🔥标识）
```

**UserPreference（偏好中心）**:
```sql
last_location        -- 位置记忆（POINT类型）⭐
privacy_*            -- 隐私设置（消息/资料/在线）
notification_*       -- 通知设置（分类开关）
```

**City（城市数据）**:
```sql
center_location      -- 中心点（POINT）⭐
city_area            -- 城市边界（POLYGON）⭐
is_open              -- 服务开通状态（灰度）
```

### 性能提升数据

| 场景 | 优化前 | 优化后 | 提升 |
|------|--------|--------|------|
| 附近服务查询（空间索引） | 500ms | 50ms | **10倍** ⭐ |
| 热搜榜单查询（Redis） | 200ms | 2ms | **100倍** ⭐ |
| 用户偏好读取（缓存） | 100ms | 2ms | **50倍** ⭐ |
| 行为数据写入（异步） | 阻塞 | 非阻塞 | **∞** ⭐ |
| 存储空间（采样+归档） | 100GB | 30GB | **节省70%** |

---

## 🔐 安全规范

### 强制要求
```yaml
认证授权:
  - JWT双令牌机制 (access_token 2h + refresh_token 30d)
  - @RequiresPermissions鉴权
  - @InnerAuth内部调用保护

密码安全:
  - BCrypt加密 (带salt)
  - 密码强度: 最少8位,含字母数字
  - 防暴力破解: 5次失败锁定30分钟

验证码:
  - 6位数字,5分钟有效
  - 每日发送上限10次
  - 最多3次验证尝试
  - 防穷举: 全局每日30次

数据保护:
  - 敏感字段使用@Sensitive脱敏
  - 身份证AES-256加密
  - SQL注入防护（参数化查询）
  - XSS防护（@Xss注解）
```

---

## 🚀 性能规范

### 缓存策略
```
Redis使用规范:
  - Key命名: {module}:{entity}:{id}
  - 统计数据: Redis主存储 + MySQL异步持久化
  - 过期策略: 热数据30min, 温数据2h, 冷数据24h
  - 缓存预热: 启动时加载核心数据

示例:
  user:profile:123
  content:stats:456
  topic:hot_list
```

### 查询优化
```
强制要求:
  ✅ 分页查询（Page<T>）
  ✅ 只查需要的字段（wrapper.select）
  ✅ 批量查询（IN替代循环）
  ❌ 禁止全表扫描
  ❌ 禁止N+1查询
```

### 异步处理
```
耗时操作异步化:
  - 短信发送 → @Async
  - 统计同步 → 消息队列
  - 日志记录 → 异步日志
  - 埋点数据 → 消息队列批量入库 🆕
```

### v7.1数据分析优化 🆕

**分区表策略**:
```
UserBehavior/SearchHistory:
  - 按日期分区（PARTITION BY RANGE）
  - 7天热数据（高速查询）
  - 30天温数据（归档）
  - 31天+冷数据（ClickHouse/OSS）
```

**空间索引**:
```sql
-- City城市数据
CREATE SPATIAL INDEX idx_center ON city(center_location);      -- POINT
CREATE SPATIAL INDEX idx_area ON city(city_area);              -- POLYGON

-- 高效查询（性能提升10倍）
WHERE ST_Distance_Sphere(location, point) < 3000              -- 3km内
WHERE ST_Contains(city_area, point)                           -- 城市边界内
```

**异步批量写入**:
```java
// 高频埋点异步入库
@RabbitListener(queues = "user.behavior.queue")
public void batchInsert(List<UserBehaviorDTO> behaviors) {
    // 采样过滤（滚动事件10%）
    List<UserBehavior> filtered = behaviors.stream()
        .filter(b -> shouldSample(b))
        .map(this::toEntity)
        .toList();
    
    // 批量插入（500条/批）
    userBehaviorMapper.insertBatch(filtered);
}
```

**Redis缓存增强**:
```
热搜榜单（Sorted Set）:
  ZADD hot_search:score {heat_score} {keyword}
  ZREVRANGE hot_search:score 0 49 → Top 50

用户偏好（Hash）:
  preference:user:{user_id} → TTL 1小时

搜索历史（List）:
  search:history:user:{user_id} → 最近10次

城市列表（永久缓存）:
  city:list → 启动加载，变更更新
```

---

## 📝 API规范

### RESTful设计
```
URL规范:
  GET    /api/v{version}/{module}/{resource}
  GET    /api/v{version}/{module}/{resource}/{id}
  POST   /api/v{version}/{module}/{resource}
  PUT    /api/v{version}/{module}/{resource}
  DELETE /api/v{version}/{module}/{resource}/{ids}

示例:
  GET    /api/v2/user/profile/123
  POST   /api/v2/content/publish
  PUT    /api/v2/user/profile
  DELETE /api/v2/content/123,456
```

### 响应格式
```json
成功: { "code": 200, "message": "成功", "data": {...} }
失败: { "code": 400, "message": "参数错误", "data": null }
分页: { "code": 200, "data": { "total": 100, "rows": [...] } }
```

---

## 🧪 测试规范

### 覆盖率要求
```
单元测试:
  - Service层: > 80%
  - Controller层: > 70%
  - 工具类: > 90%

集成测试:
  - 核心API: 100%覆盖
  - 异常场景: 必须覆盖
```

---

## 📋 开发检查清单

### 提交代码前
```
✅ 编译无警告
✅ 单元测试通过
✅ Knife4j文档生成
✅ 代码格式化完成
✅ 无硬编码配置
✅ 异常正确处理
✅ 日志正确记录
```

### 功能完成前
```
✅ API文档完整
✅ 测试覆盖达标
✅ 性能测试通过（P95 < 300ms）
✅ Code Review通过
```

---

## 🚫 禁止清单（零容忍）

```
❌ System.out.println
❌ 硬编码密码/密钥
❌ catch Exception不处理
❌ SELECT *
❌ 魔法数字（使用常量）
❌ Controller调用Mapper
❌ Entity包含业务逻辑
❌ 明文存储密码
❌ 跨服务直连数据库
❌ 忽略编译警告
```

---

## 📐 ADR架构决策（8个）

### ADR-001: 统计数据分离
```yaml
决策: 统计字段与业务数据分离
方案: 独立统计表 + Redis缓存
理由: 
  - 解决高并发更新冲突
  - 支持异步同步
  - 避免锁竞争
实施:
  UserProfile → UserStats
  Content → ContentStats
  Topic → TopicStats
  GameService/LifeService → ServiceStats
```

### ADR-002: 空间索引优化
```yaml
决策: 使用MySQL空间索引
方案: POINT/POLYGON类型 + SPATIAL INDEX
理由:
  - ST_Distance_Sphere()性能提升10倍
  - 原生数据库支持
  - 避免应用层计算
实施:
  Content: location POINT SRID 4326
  City: center_location POINT, city_area POLYGON
  CREATE SPATIAL INDEX idx_location
```

### ADR-003: 消息分片策略
```yaml
决策: ChatMessage按会话ID分片
方案: 256张表，按conversation_id % 256哈希
理由:
  - 单表数据量可控
  - 查询性能稳定
  - 归档方便
实施:
  chat_message_000 ~ chat_message_255
```

### ADR-004: JSON vs 字段展开
```yaml
MVP阶段: JSON灵活扩展（快速迭代）
  UserProfile.metadata: {email, bio, location...}

生产阶段: 字段完全展开（性能优先）
  UserProfile: email, bio, location, height, weight...

迁移策略: 双写 → 灰度切换 → 废弃JSON
```

### ADR-005: 行为数据分区表 🆕
```yaml
决策: UserBehavior使用日期分区表
方案: PARTITION BY RANGE (TO_DAYS(date_partition))
理由:
  - 单表数据量巨大（百万/千万级）
  - 查询主要集中在近期数据
  - 历史数据归档需求
  - 删除分区比DELETE快1000倍
实施:
  - 每日自动创建新分区
  - 7天热数据（当前分区）
  - 8-30天温数据（归档分区）
  - 31天+冷数据（导出ClickHouse/OSS）
性能:
  - 查询今日：只扫描1个分区（提升5倍+）
  - 删除冷数据：DROP PARTITION（秒级）
```

### ADR-006: 异步批量写入 🆕
```yaml
决策: 高频埋点数据异步批量入库
方案: RabbitMQ消息队列 + 定时批量INSERT
理由:
  - 埋点QPS高（每秒数千次）
  - 同步写入阻塞用户请求
  - 单条INSERT效率低
实施:
  - 前端埋点 → 消息队列
  - 后端监听 → 10秒批次（500条）
  - 批量INSERT → 失败重试3次
性能:
  - 用户无感知（非阻塞）
  - 数据库压力降低95%
  - 吞吐量提升100倍+
```

### ADR-007: 高频事件采样 🆕
```yaml
决策: 滚动/心跳等高频事件采样存储
方案: 10%随机采样 + 关键事件100%
理由:
  - 滚动事件每秒几十次（数据爆炸）
  - 全量存储价值不大
  - 采样10%足够分析
实施:
  - 滚动事件：10%采样
  - 心跳事件：10%采样
  - 关键事件：100%（点击/下单/支付）
  - 随机算法：Math.random() < 0.1
性能:
  - 存储量减少90%
  - 分析精度损失<5%
```

### ADR-008: 城市空间边界 🆕
```yaml
决策: 使用POLYGON存储城市边界
方案: city_area POLYGON + ST_Contains判断
理由:
  - 精准判断坐标是否在城市内
  - 支持不规则边界（海岸线）
  - 原生数据库支持，性能高
实施:
  - 导入城市边界GeoJSON
  - 转换为POLYGON格式
  - CREATE SPATIAL INDEX
  - ST_Contains(city_area, user_point)
应用:
  - IP定位自动匹配城市
  - 服务推荐同城优先
  - 地域运营精准投放
```

---

## 🎯 性能指标（SLA）

### 响应时间
```
P95: < 300ms
P99: < 500ms
超时: 3s (服务调用超时时间)
```

### 并发能力
```
登录接口: 1000 QPS
内容列表: 2000 QPS
消息发送: 500 QPS
```

### 可用性
```
系统可用性: > 99.9% (年停机 < 8.76h)
数据一致性: 最终一致性 (< 10s)
```

---

## 🛠️ 开发环境

### 本地环境要求
```
必装软件:
  - JDK 21
  - Maven 3.8+
  - MySQL 8.0+
  - Redis 7.0+
  - Nacos 2.x
  - IntelliJ IDEA 2024+

IDEA插件:
  - Lombok
  - MyBatis X
  - Alibaba Java Coding Guidelines
  - SonarLint
```

### Docker一键启动
```bash
cd docker
docker-compose up -d mysql redis nacos
```

---

## 📊 监控规范

### 日志规范
```java
使用@Slf4j:
  log.info("用户登录, mobile={}", mobile);  // ✅
  System.out.println("登录成功");           // ❌

日志级别:
  ERROR: 系统错误、异常
  WARN:  业务异常、降级
  INFO:  关键操作、状态变更
  DEBUG: 调试信息（生产关闭）
```

### 健康检查
```
每个服务必须实现:
  /actuator/health
  /actuator/metrics
  /actuator/prometheus
```

---

## 🔄 Git规范

### 分支策略
```
main      → 生产环境（受保护）
develop   → 开发环境
feature/* → 功能分支
hotfix/*  → 紧急修复
```

### 提交规范
```
格式: <type>(<scope>): <subject>

类型:
  feat:     新功能
  fix:      Bug修复
  refactor: 重构
  perf:     性能优化
  docs:     文档更新
  test:     测试相关

示例:
  feat(auth): 添加短信登录功能
  fix(user): 修复用户资料更新失败
  refactor(content): 重构内容查询逻辑
```

---

## 📚 文档要求

### API文档
```
强制Knife4j注解:
  @Tag(name = "用户管理")
  @Operation(summary = "获取用户详情")
  @Parameter(description = "用户ID", required = true)
  
访问地址:
  http://localhost:{port}/doc.html
```

### 代码注释
```java
类注释:
/**
 * 用户服务实现类
 * 
 * @author {姓名}
 * @date {日期}
 */

方法注释:
/**
 * 获取用户详细信息
 * 
 * @param userId 用户ID
 * @return 用户详细信息
 * @throws ServiceException 用户不存在时抛出
 */
```

---

## 🎯 团队分工技术栈

### 后端组（6人）
```
Alice - 认证安全:
  Spring Security + JWT + BCrypt + 短信服务

Bob - 用户服务:
  MyBatis Plus + Redis + 统计系统

Charlie/David - 内容服务:
  MyBatis Plus + 空间索引 + 评论系统

Eve - 聊天服务:
  WebSocket + 消息分片 + Redis

Frank - 交易活动:
  分布式事务 + 订单系统 + 钱包

公共技能:
  - Spring Cloud全家桶
  - MySQL优化
  - Redis缓存
```

### 前端组（3人）
```
Grace - 首页/组局:
  Vue 3 + 推荐流 + 地图组件

Henry - 发现页:
  瀑布流 + 评论组件 + 话题系统

Ivy - 个人/消息:
  WebSocket + 实时通信 + 个人中心

公共技能:
  - Vue 3 Composition API
  - Element Plus
  - Axios拦截器
```

### 支持组（2人）
```
Jack - DBA:
  - MySQL 8.0空间索引
  - 分表分库
  - 性能调优
  - 数据迁移脚本

Kate - QA:
  - JUnit 5 + Mockito
  - Postman/JMeter
  - 性能测试
  - 自动化测试
```

---

## ⚙️ 配置规范

### application.yml模板
```yaml
spring:
  application:
    name: xypai-{module}
  
  datasource:
    dynamic:
      primary: master
      datasource:
        master:
          url: jdbc:mysql://localhost:3306/xypai_{module}
          username: ${DB_USER:root}
          password: ${DB_PWD:password}
  
  redis:
    host: ${REDIS_HOST:localhost}
    port: ${REDIS_PORT:6379}
    database: ${REDIS_DB:0}

mybatis-plus:
  configuration:
    map-underscore-to-camel-case: true
    log-impl: org.apache.ibatis.logging.stdout.StdOutImpl
```

---

## 🎯 10人团队实施指南

### v7.1升级任务分配（2周完成）

| 角色 | 工作量 | 关键任务 | 难度 |
|------|--------|---------|------|
| Jack (DBA) | 2天 | DDL+空间索引+分区表+压测 | ⭐⭐⭐⭐⭐ |
| Bob (用户) | 3天 | UserPreference+City服务 | ⭐⭐⭐⭐ |
| Charlie (内容) | 4天 | UserBehavior+Search+定时任务 | ⭐⭐⭐⭐⭐ |
| David (内容) | 0天 | 协助Charlie | - |
| Eve (聊天) | 0天 | 无需改动 | - |
| Frank (交易) | 1天 | 转化数据对接 | ⭐⭐ |
| Grace (前端) | 2天 | 埋点集成+筛选组件 | ⭐⭐⭐ |
| Henry (前端) | 2天 | 搜索埋点+热搜榜单 | ⭐⭐⭐ |
| Ivy (前端) | 1天 | 偏好设置页面 | ⭐⭐ |
| Kate (QA) | 2天 | 功能+性能测试 | ⭐⭐⭐ |

**总工作量**: 17人天

### 实施时间线

```
Week 1: 数据库+后端
  Day 1-2: Jack → DDL+索引+分区
  Day 3-4: 后端 → Entity+Service
  Day 5:   后端 → 异步写入+定时任务

Week 2: 前端+测试+上线
  Day 1-2: 前端 → 埋点集成
  Day 3:   Kate → 集成测试
  Day 4:   Kate → 性能压测
  Day 5:   全员 → 灰度上线（5%→100%）
```

### 关键代码示例

**后端埋点接收**:
```java
@PostMapping("/api/v1/behavior/track")
public R<Void> track(@RequestBody UserBehaviorDTO dto) {
    // 发送到消息队列（异步）
    rabbitTemplate.convertAndSend("user.behavior.queue", dto);
    return R.ok();
}
```

**前端埋点上报**:
```javascript
// 页面浏览
trackBehavior({
  behaviorType: 1,        // 浏览
  targetType: 2,          // 内容
  targetId: contentId,
  sessionId: getSessionId(),
  scrollDepth: 85,
  durationSeconds: 120
});

// 转化事件
trackConversion({
  behaviorType: 9,        // 支付
  isConversion: true,
  conversionType: 1,      // 下单转化
  conversionValue: 9900   // 99元
});
```

**空间查询**:
```sql
-- 查询用户3km内的服务
SELECT *, 
  ST_Distance_Sphere(location, ST_GeomFromText('POINT(114.05 22.55)', 4326)) / 1000 AS distance
FROM life_service
WHERE ST_Distance_Sphere(location, ST_GeomFromText('POINT(114.05 22.55)', 4326)) <= 3000
ORDER BY distance LIMIT 20;
```

**热搜榜单**:
```java
// Redis查询Top 50
Set<ZSetOperations.TypedTuple<String>> result = 
    redisTemplate.opsForZSet()
        .reverseRangeWithScores("hot_search:score", 0, 49);
```

---

## 🔍 关键概念（必须理解）

### 1. 会话追踪（session_id）
```
作用：关联用户单次访问的所有行为

流程：
用户A打开App
  ├─ 生成session_id: "uuid-123"
  ├─ 浏览首页 → behavior(session_id)
  ├─ 搜索"陪玩" → search(session_id)
  ├─ 点击服务 → behavior(session_id)
  └─ 下单支付 → behavior(session_id, is_conversion=true)

价值：完整的转化路径分析
```

### 2. 转化分析（conversion）
```
定义：用户完成了我们期望的动作

类型：
  浏览→点赞   (conversion_type=6, value=1)
  搜索→下单   (conversion_type=1, value=订单金额)
  查看→关注   (conversion_type=2, value=1)

应用：直接统计转化率，优化漏斗环节
```

### 3. 空间索引（POINT/POLYGON）
```sql
-- 传统方式（慢，无索引）
WHERE SQRT(POW(lng-114.05,2) + POW(lat-22.55,2)) < 0.03

-- 空间索引（快10倍，自动优化）
WHERE ST_Distance_Sphere(location, POINT(114.05, 22.55)) < 3000
```

### 4. 分区表（date_partition）
```
优势：
  - 查询今日：只扫描1个分区（速度快5倍）
  - 查询历史：自动分区裁剪
  - 删除冷数据：DROP PARTITION（秒删）
  
MySQL自动管理，业务无感知
```

---

## 🎯 核心原则（记住这5+3条）

### 基础原则（5条）
```
1. 继承BaseEntity、使用R<T>、遵循四层架构
2. 优先MyBatis Plus，少写XML，使用LambdaQueryWrapper
3. 统计数据用独立表+Redis，不冗余在业务表
4. 安全三要素：@RequiresPermissions、@Log、参数校验
5. 异常必须处理，日志必须记录，测试必须覆盖
```

### v7.1新增原则（3条）🆕
```
6. 大数据量表必须分区（UserBehavior/SearchHistory）
7. 地理查询必须用空间索引（POINT/POLYGON + SPATIAL INDEX）
8. 高频操作必须异步（埋点批量入库，采样存储）
```

---

## 📋 v7.1变更清单

### 表结构变更（114个字段）
```diff
UserBehavior:    +16字段（session_id/scroll_depth/is_conversion/date_partition...）
SearchHistory:   +10字段（keyword_normalized/first_click_position/is_satisfied...）
HotSearch:       +15字段（trend_score/rank_position/is_rising...）
UserPreference:  +15字段（last_location/privacy_*/notification_*...）
City:            +15字段（center_location/city_area/is_open...）
```

### 索引变更（20个新索引）
```sql
-- 分区表索引
idx_partition ON user_behavior(date_partition)
idx_partition ON search_history(date_partition)

-- 空间索引
SPATIAL INDEX idx_center ON city(center_location)
SPATIAL INDEX idx_area ON city(city_area)
SPATIAL INDEX idx_last_location ON user_preference(last_location)

-- 业务索引
idx_conversion ON user_behavior(is_conversion, conversion_type, created_at)
idx_session ON user_behavior(session_id, created_at)
uk_keyword ON hot_search(keyword_normalized)
idx_trend ON hot_search(is_rising, trend_score DESC)
```

### 依赖新增
```xml
<!-- 后端 -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-amqp</artifactId>  <!-- RabbitMQ -->
</dependency>
<dependency>
    <groupId>org.locationtech.jts</groupId>
    <artifactId>jts-core</artifactId>
    <version>1.19.0</version>  <!-- 空间数据处理 -->
</dependency>
```

---

## ❓ 常见问题FAQ

**Q1: 为什么UserBehavior要异步写入？**  
A: 埋点每秒数千次，同步写入会阻塞用户。异步批量性能提升100倍+。

**Q2: 为什么要采样存储？**  
A: 滚动事件每秒几十次，10%采样足够分析，节省90%存储。

**Q3: session_id如何生成？**  
A: 前端App启动时生成UUID，30分钟不活动则重新生成。

**Q4: 空间索引如何使用？**  
A: 使用ST_Distance_Sphere()函数，MySQL自动使用SPATIAL INDEX。

**Q5: 分区表如何查询？**  
A: 正常查询即可，MySQL自动分区裁剪（WHERE date_partition = CURRENT_DATE）。

---

**技术栈锁定，架构规范统一，质量标准明确。**

**v7.1升级：数据分析能力全面提升！** 📊🚀

