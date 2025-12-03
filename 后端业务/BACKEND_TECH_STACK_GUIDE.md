# XiangYuPai Backend Quick Start Guide

> **Target**: Junior Backend Developers
> **Version**: v3.0 (Concise Edition)
> **Last Updated**: 2025-11-13
> **Reading Time**: 20 minutes

**Two Core Principles:**
1. **MVP First** - Simple, working solution beats perfect architecture
2. **"Feed Grandpa"** - Code so clear even grandpa can understand

---

## Table of Contents

1. [Quick Start](#quick-start)
2. [Core Stack](#core-stack)
3. [Project Structure](#project-structure)
4. [Gateway & Remote Calls](#gateway--remote-calls)
5. [Nacos Configuration](#nacos-configuration)
6. [Database Examples](#database-examples)
7. [Common Patterns](#common-patterns)
8. [Troubleshooting](#troubleshooting)

---

## Quick Start

### Environment Setup (5 minutes)

```bash
# 1. Start infrastructure (Docker)
cd docker
docker-compose up -d mysql redis nacos

# 2. Verify services
docker ps  # All 3 containers should be running
curl http://localhost:8848/nacos/  # Nacos UI

# 3. Create database
mysql -u root -p < sql/xypai_user.sql

# 4. Start Gateway first (generates Same-Token)
cd ruoyi-gateway && mvn spring-boot:run

# 5. Start your service
cd xypai-user && mvn spring-boot:run

# 6. Test API
curl http://localhost:8080/user/api/v1/test
```

---

## Core Stack

### Technology Matrix

| Layer | Tech | Version | Why |
|-------|------|---------|-----|
| **Language** | Java | 21 (LTS) | Latest stable |
| **Framework** | Spring Boot | 3.2.0 | Industry standard |
| **Gateway** | Spring Cloud Gateway | WebFlux | Non-blocking |
| **Registry** | Nacos | 2.x | Discovery + Config |
| **RPC** | Dubbo | 3.x | High-performance calls |
| **Database** | MySQL | 8.0+ | Spatial indexes |
| **ORM** | MyBatis Plus | 3.5.7 | No XML needed |
| **Cache** | Redis | 7.0+ | Hot data |
| **Auth** | Sa-Token | Latest | JWT + permissions |

### Dependency Hierarchy

```
xypai-user (Your Service)
  ├── ruoyi-common-security   (Auth + Sa-Token)
  ├── ruoyi-common-redis      (Cache)
  ├── ruoyi-common-mybatis    (Database)
  ├── ruoyi-common-dubbo      (RPC)
  ├── ruoyi-common-tenant     (Multi-tenancy - optional)
  └── ruoyi-common-web        (Web utilities)
```

**CRITICAL**: Never add `ruoyi-common-satoken` directly - it's included in `ruoyi-common-security`!

---

## Project Structure

### Standard Service Layout

```
xypai-user/
├── src/main/java/org/dromara/user/
│   ├── controller/           # REST APIs
│   │   ├── admin/           # Admin endpoints
│   │   ├── app/             # User endpoints
│   │   └── feign/           # Internal RPC
│   ├── service/             # Business logic
│   │   ├── IUserService.java
│   │   ├── impl/
│   │   │   └── UserServiceImpl.java
│   │   └── remote/          # Remote service calls
│   │       └── RemoteContentServiceImpl.java
│   ├── mapper/              # MyBatis mappers
│   │   └── UserMapper.java
│   └── domain/              # Data models
│       ├── entity/          # Database entities (@TableName)
│       │   └── User.java
│       ├── dto/             # Request objects
│       │   ├── UserAddDTO.java
│       │   └── UserQueryDTO.java
│       └── vo/              # Response objects
│           └── UserDetailVO.java
├── src/main/resources/
│   ├── application.yml       # Main config
│   ├── application-dev.yml   # Dev environment
│   └── bootstrap.yml         # Nacos bootstrap
└── pom.xml
```

### Entity Example (MVP Style)

```java
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@TableName("user")
public class User implements Serializable {

    @TableId(type = IdType.ASSIGN_ID)
    private Long userId;

    private String nickname;
    private String avatar;
    private String mobile;
    private Integer gender;

    @TableLogic
    private Integer deleted;  // Soft delete

    @Version
    private Integer version;  // Optimistic lock

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
```

**Key Points:**
- `@Builder` - Clean object creation
- `@TableLogic` - Soft delete (UPDATE deleted=1)
- `@Version` - Prevents concurrent update conflicts
- No XML mappers needed!

---

## Gateway & Remote Calls

### Gateway Architecture

```
Client Request
    ↓
Gateway (8080) - Same-Token generated
    ↓
Microservice (9401) - Same-Token validated
    ↓
Response
```

### Gateway Configuration

**Gateway: application.yml**

```yaml
spring:
  cloud:
    gateway:
      routes:
        - id: xypai-user
          uri: lb://xypai-user  # Load-balanced
          predicates:
            - Path=/user/**
          filters:
            - StripPrefix=1
            - name: RequestRateLimiter
              args:
                redis-rate-limiter.replenishRate: 100
                redis-rate-limiter.burstCapacity: 200

# Sa-Token Gateway Integration
sa-token:
  check-same-token: true  # Enable Same-Token validation
```

### Same-Token Flow (Critical!)

**Problem**: How do microservices know the request is from Gateway?

**Solution**: Same-Token (shared secret)

1. **Gateway generates Same-Token** on startup
2. **Stores in Redis**: `key = "satoken:var:same-token"`
3. **Adds to every request**: `Same-Token: eC5Gr...` (Header)
4. **Microservice validates**: Checks if request token matches Redis value

**Gateway: ForwardAuthFilter.java**

```java
@Component
public class ForwardAuthFilter implements GlobalFilter {

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        // Add Same-Token to request
        ServerHttpRequest request = exchange.getRequest().mutate()
            .header("Same-Token", SaTokenManager.getSameToken())
            .build();

        return chain.filter(exchange.mutate().request(request).build());
    }
}
```

**Microservice: SecurityConfiguration.java**

```java
@Configuration
public class SecurityConfiguration {

    @Bean
    public SaTokenConfigure getSaTokenConfigBean() {
        return new SaTokenConfigure();
    }
}
```

**That's it!** Sa-Token handles validation automatically if:
- ✅ POM dependencies are correct
- ✅ `check-same-token: true` in config
- ✅ All services use same Redis

### Dubbo Remote Calls

**Scenario**: User Service needs to query content from Content Service.

**Step 1: Define API Interface** (in `ruoyi-api/ruoyi-api-content`)

```java
package org.dromara.content.api;

public interface RemoteContentService {

    /**
     * Get content details by ID
     */
    R<ContentDetailVO> getContentDetail(Long contentId);

    /**
     * Get user's content list
     */
    R<List<ContentListVO>> getUserContents(Long userId, Integer limit);
}
```

**Step 2: Implement in Content Service** (xypai-content)

```java
@DubboService  // ← Dubbo RPC provider
@Service
@RequiredArgsConstructor
public class RemoteContentServiceImpl implements RemoteContentService {

    private final IContentService contentService;

    @Override
    public R<ContentDetailVO> getContentDetail(Long contentId) {
        ContentDetailVO content = contentService.getDetail(contentId);
        return R.ok(content);
    }

    @Override
    public R<List<ContentListVO>> getUserContents(Long userId, Integer limit) {
        List<ContentListVO> list = contentService.listByUser(userId, limit);
        return R.ok(list);
    }
}
```

**Step 3: Call from User Service** (xypai-user)

```java
@Service
@RequiredArgsConstructor
public class UserServiceImpl implements IUserService {

    @DubboReference  // ← Dubbo RPC consumer
    private RemoteContentService remoteContentService;

    @Override
    public UserProfileVO getUserProfile(Long userId) {
        // Get user basic info
        User user = userMapper.selectById(userId);

        // Call remote service to get user's contents
        R<List<ContentListVO>> result = remoteContentService.getUserContents(userId, 10);
        List<ContentListVO> contents = result.getData();

        // Build response
        return UserProfileVO.builder()
            .userId(user.getUserId())
            .nickname(user.getNickname())
            .contents(contents)  // From Content Service
            .build();
    }
}
```

**Key Points:**
- `@DubboService` - Publish service
- `@DubboReference` - Consume service
- Service auto-registered in Nacos
- No manual HTTP calls needed!

---

## Nacos Configuration

### Bootstrap Configuration

**bootstrap.yml** (Loaded first, before application.yml)

```yaml
spring:
  application:
    name: xypai-user  # Service name (MUST be unique)

  cloud:
    nacos:
      # Service Discovery
      discovery:
        server-addr: ${NACOS_SERVER:localhost:8848}
        namespace: ${NACOS_NAMESPACE:dev}  # dev/test/prod
        group: DEFAULT_GROUP

      # Dynamic Configuration
      config:
        server-addr: ${NACOS_SERVER:localhost:8848}
        namespace: ${NACOS_NAMESPACE:dev}
        group: DEFAULT_GROUP
        file-extension: yml
        shared-configs:
          - data-id: common-redis.yml
            group: DEFAULT_GROUP
            refresh: true
          - data-id: common-mysql.yml
            group: DEFAULT_GROUP
            refresh: true
```

### Nacos Configuration Files

**1. Create `xypai-user-dev.yml` in Nacos console:**

```yaml
# Database (Module-specific)
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/xypai_user?useSSL=false
    username: root
    password: ${MYSQL_PASSWORD:password}

# Business configuration
xypai:
  user:
    max-nickname-length: 30
    default-avatar: https://cdn.example.com/default-avatar.png
```

**2. Create `common-redis.yml` (Shared):**

```yaml
spring:
  redis:
    host: ${REDIS_HOST:localhost}
    port: ${REDIS_PORT:6379}
    password: ${REDIS_PASSWORD:}
    database: 0
    timeout: 10000ms
    lettuce:
      pool:
        max-active: 20
        max-idle: 10
        min-idle: 5
```

**3. Create `common-mysql.yml` (Shared):**

```yaml
spring:
  datasource:
    type: com.zaxxer.hikari.HikariDataSource
    driver-class-name: com.mysql.cj.jdbc.Driver
    hikari:
      maximum-pool-size: 20
      minimum-idle: 10
      connection-timeout: 30000
```

### Dynamic Configuration Refresh

```java
@RefreshScope  // ← Auto-refresh when Nacos config changes
@Configuration
public class UserConfig {

    @Value("${xypai.user.max-nickname-length:30}")
    private Integer maxNicknameLength;

    @Value("${xypai.user.default-avatar}")
    private String defaultAvatar;

    // Getters
}
```

---

## Database Examples

### Database: xypai_user

**Design Principle**: Business attributes only (no auth fields)

```sql
CREATE TABLE `user` (
    -- === Primary Key ===
    `user_id`       BIGINT(20)      NOT NULL AUTO_INCREMENT,

    -- === Basic Info ===
    `nickname`      VARCHAR(50)     NOT NULL,
    `avatar`        VARCHAR(500),
    `gender`        TINYINT(1)      DEFAULT 0,  -- 0=secret, 1=male, 2=female
    `birthday`      DATE,
    `bio`           VARCHAR(500),

    -- === Location ===
    `city_id`       BIGINT(20),
    `location`      POINT SRID 4326,  -- Spatial index
    `address`       VARCHAR(200),

    -- === Status ===
    `online_status` TINYINT(1)      DEFAULT 1,  -- 1=online, 2=busy, 3=offline
    `vip_level`     TINYINT(1)      DEFAULT 0,

    -- === Audit Fields (MANDATORY) ===
    `created_at`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted`       TINYINT(1)      NOT NULL DEFAULT 0,  -- Soft delete
    `version`       INT(11)         NOT NULL DEFAULT 0,  -- Optimistic lock

    PRIMARY KEY (`user_id`),
    KEY `idx_city_id` (`city_id`),
    SPATIAL KEY `idx_location` (`location`),  -- For nearby queries
    KEY `idx_deleted` (`deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='User business info (no auth)';
```

**Why split from sys_user?**
- `ruoyi-system.sys_user`: Authentication (username, password, roles)
- `xypai-user.user`: Business attributes (nickname, avatar, bio)

### MyBatis Plus Queries (No XML!)

**1. Simple Query:**

```java
// Find by ID
User user = userMapper.selectById(123L);

// Find by nickname
LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
wrapper.eq(User::getNickname, "Alice");
User user = userMapper.selectOne(wrapper);
```

**2. Complex Query with Conditions:**

```java
@Override
public List<UserListVO> searchUsers(UserQueryDTO query) {
    LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();

    // Dynamic conditions
    if (StringUtils.isNotEmpty(query.getNickname())) {
        wrapper.like(User::getNickname, query.getNickname());
    }
    if (query.getGender() != null) {
        wrapper.eq(User::getGender, query.getGender());
    }
    if (query.getCityId() != null) {
        wrapper.eq(User::getCityId, query.getCityId());
    }

    // Sort and limit
    wrapper.orderByDesc(User::getCreatedAt);
    wrapper.last("LIMIT " + query.getLimit());

    return userMapper.selectList(wrapper);
}
```

**3. Spatial Query (Nearby Users):**

```java
@Select("""
    SELECT *,
      ST_Distance_Sphere(location, ST_GeomFromText(#{point}, 4326)) / 1000 AS distance_km
    FROM user
    WHERE ST_Distance_Sphere(location, ST_GeomFromText(#{point}, 4326)) <= #{radiusMeters}
      AND deleted = 0
    ORDER BY distance_km
    LIMIT #{limit}
    """)
List<User> findNearbyUsers(
    @Param("point") String point,         // "POINT(114.05 22.55)"
    @Param("radiusMeters") int radiusMeters,  // 3000 = 3km
    @Param("limit") int limit
);

// Usage
String userLocation = "POINT(114.05 22.55)";
List<User> nearby = userMapper.findNearbyUsers(userLocation, 3000, 20);
```

**4. Batch Operations:**

```java
// Batch insert (100x faster than loop)
List<User> users = new ArrayList<>();
for (int i = 0; i < 1000; i++) {
    users.add(User.builder()
        .nickname("User" + i)
        .gender(i % 2)
        .build());
}
userMapper.insertBatch(users);  // One transaction

// Batch query (avoid N+1)
List<Long> userIds = Arrays.asList(1L, 2L, 3L, 4L, 5L);
LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
wrapper.in(User::getUserId, userIds);
List<User> users = userMapper.selectList(wrapper);
```

---

## Common Patterns

### Pattern 1: Cache-Aside

```java
@Override
public UserDetailVO getUserDetail(Long userId) {
    String cacheKey = "user:detail:" + userId;

    // 1. Try cache
    UserDetailVO cached = redisService.getCacheObject(cacheKey);
    if (cached != null) {
        return cached;
    }

    // 2. Query database
    User user = userMapper.selectById(userId);
    if (user == null) {
        throw new ServiceException("User not found");
    }

    // 3. Build VO
    UserDetailVO vo = convertToVO(user);

    // 4. Store in cache (30 minutes)
    redisService.setCacheObject(cacheKey, vo, Duration.ofMinutes(30));

    return vo;
}

@Override
@Transactional(rollbackFor = Exception.class)
public void updateUser(UserUpdateDTO dto) {
    // Update database
    User user = convertToEntity(dto);
    userMapper.updateById(user);

    // Invalidate cache
    redisService.deleteObject("user:detail:" + dto.getUserId());
}
```

### Pattern 2: Async Processing

```java
@Service
@RequiredArgsConstructor
public class NotificationService {

    private final RabbitTemplate rabbitTemplate;

    public void sendWelcomeEmail(Long userId) {
        // Non-blocking - send to queue
        EmailMessage message = EmailMessage.builder()
            .userId(userId)
            .type("welcome")
            .build();

        rabbitTemplate.convertAndSend("email.queue", message);
    }
}

@Component
@RequiredArgsConstructor
public class EmailConsumer {

    @RabbitListener(queues = "email.queue")
    public void handleEmailMessage(EmailMessage message) {
        // Process asynchronously
        emailClient.send(message);
    }
}
```

### Pattern 3: Pagination

```java
@Override
public Page<UserListVO> listUsers(UserQueryDTO query) {
    // Build page
    Page<User> page = new Page<>(query.getPageNum(), query.getPageSize());

    // Build query
    LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
    wrapper.eq(query.getGender() != null, User::getGender, query.getGender())
           .orderByDesc(User::getCreatedAt);

    // Execute paginated query
    Page<User> result = userMapper.selectPage(page, wrapper);

    // Convert to VOs
    List<UserListVO> voList = result.getRecords().stream()
        .map(this::convertToListVO)
        .toList();

    // Return paginated result
    Page<UserListVO> voPage = new Page<>();
    voPage.setRecords(voList);
    voPage.setTotal(result.getTotal());
    voPage.setCurrent(result.getCurrent());
    voPage.setSize(result.getSize());

    return voPage;
}
```

---

## Troubleshooting

### Issue 1: Same-Token Validation Fails

**Symptom:**
```
❌ Same-Token验证失败: 无效Same-Token
   请求中的 Same-Token: eC5Gr...
   期望的 Same-Token: tc8by...
```

**Root Cause**: Duplicate `ruoyi-common-satoken` in POM

**Solution:**

```xml
<!-- ❌ WRONG: Duplicate dependency -->
<dependency>
    <groupId>org.dromara</groupId>
    <artifactId>ruoyi-common-security</artifactId>
</dependency>
<dependency>
    <groupId>org.dromara</groupId>
    <artifactId>ruoyi-common-satoken</artifactId>  <!-- ⚠️ Remove this! -->
</dependency>

<!-- ✅ CORRECT: Only security (includes satoken) -->
<dependency>
    <groupId>org.dromara</groupId>
    <artifactId>ruoyi-common-security</artifactId>
</dependency>
```

### Issue 2: Nacos Service Not Found

**Symptom:**
```
No provider available for service: org.dromara.content.api.RemoteContentService
```

**Solution:**

1. Check service is running: `curl http://localhost:9403/actuator/health`
2. Check Nacos registry: `curl http://localhost:8848/nacos/v1/ns/instance/list?serviceName=xypai-content`
3. Verify `@DubboService` on provider
4. Verify `@DubboReference` on consumer

### Issue 3: Database Connection Pool Exhausted

**Symptom:**
```
Cannot get connection, pool exhausted
```

**Solution:**

```yaml
spring:
  datasource:
    hikari:
      maximum-pool-size: 50  # Increase from 20
      connection-timeout: 30000
      max-lifetime: 1800000
```

### Issue 4: Redis Connection Timeout

**Symptom:**
```
RedisCommandTimeoutException: Command timed out
```

**Solution:**

```yaml
spring:
  redis:
    timeout: 10000ms  # 10 seconds
    lettuce:
      pool:
        max-active: 20
        max-wait: 10000ms
```

---

## Standard POM Template

**Use this for all xypai services:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0">
    <parent>
        <groupId>org.dromara</groupId>
        <artifactId>ruoyi-cloud-plus</artifactId>
        <version>${revision}</version>
    </parent>
    <modelVersion>4.0.0</modelVersion>

    <artifactId>xypai-xxx</artifactId>

    <dependencies>
        <!-- Core -->
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

        <!-- Security (includes satoken) -->
        <dependency>
            <groupId>org.dromara</groupId>
            <artifactId>ruoyi-common-security</artifactId>
        </dependency>

        <!-- Cache -->
        <dependency>
            <groupId>org.dromara</groupId>
            <artifactId>ruoyi-common-redis</artifactId>
        </dependency>

        <!-- RPC -->
        <dependency>
            <groupId>org.dromara</groupId>
            <artifactId>ruoyi-common-dubbo</artifactId>
        </dependency>

        <!-- Optional -->
        <dependency>
            <groupId>org.dromara</groupId>
            <artifactId>ruoyi-common-tenant</artifactId>
        </dependency>
        <dependency>
            <groupId>org.dromara</groupId>
            <artifactId>ruoyi-common-translation</artifactId>
        </dependency>

        <!-- API Documentation -->
        <dependency>
            <groupId>org.dromara</groupId>
            <artifactId>ruoyi-common-doc</artifactId>
        </dependency>

        <!-- Logging -->
        <dependency>
            <groupId>org.dromara</groupId>
            <artifactId>ruoyi-common-log</artifactId>
        </dependency>
    </dependencies>
</project>
```

---

## Quick Reference

### Daily Workflow

```bash
# Morning startup
docker-compose up -d           # Infrastructure
cd ruoyi-gateway && mvn spring-boot:run  # Gateway first
cd xypai-user && mvn spring-boot:run     # Your service

# Before commit
mvn clean test                 # Run tests
mvn checkstyle:check          # Code style
git add . && git commit -m "feat(user): add profile API"

# API testing
open http://localhost:9401/doc.html  # Knife4j
```

### Key Commands

```bash
# Check service health
curl http://localhost:9401/actuator/health

# View Nacos services
curl http://localhost:8848/nacos/v1/ns/instance/list?serviceName=xypai-user

# Check Redis
redis-cli
> KEYS *
> GET satoken:var:same-token

# Database query
mysql -u root -p xypai_user
> SELECT * FROM user LIMIT 10;
```

### Remember

1. **Start Gateway first** - It generates Same-Token
2. **Never duplicate dependencies** - Trust Maven transitive dependencies
3. **Use LambdaQueryWrapper** - Type-safe, no XML
4. **Cache hot data** - Redis for frequently accessed data
5. **Async heavy operations** - Don't block user requests

---

**Document Version**: v3.0 (Concise)
**Last Updated**: 2025-11-13
**Maintained By**: XiangYuPai Team

**Questions?** Check logs first, then [TESTING_GUIDE.md](e:/Users/Administrator/Documents/GitHub/RuoYi-Cloud-Plus/xypai-auth/TESTING_GUIDE.md) for debugging.
