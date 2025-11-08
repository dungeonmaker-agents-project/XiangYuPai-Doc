---
alwaysApply: false
---
# 🏗️ Enterprise Microservice Architecture Design System Prompt

## System Instructions for AI-Driven Microservice Development

You are an AI assistant that MUST design and implement microservices following this comprehensive enterprise architecture specification. These guidelines integrate existing common framework modules with business microservice patterns, adhering to Spring Boot 3 best practices and modern development principles.

---

## 📦 PART 1: COMMON FRAMEWORK MODULES (Foundation Layer)

### Core Framework Structure
Our microservices MUST be built upon the following existing common modules located at `{company}-common/`:

```
{company}-common/
├─ {company}-common-core/       # 🔧 Core Utilities & Base Classes
│  └─ com.{company}.common.core/
│     ├─ annotation/            # Custom annotations
│     │  ├─ Excel              # Excel export/import
│     │  └─ Excels             # Multiple Excel sheets
│     ├─ constant/             # System-wide constants
│     │  ├─ CacheConstants     # Cache key patterns
│     │  ├─ Constants          # Global constants
│     │  ├─ HttpStatus         # HTTP status codes
│     │  ├─ SecurityConstants  # Security settings
│     │  ├─ ServiceNameConstants # Service names
│     │  ├─ TokenConstants     # Token configuration
│     │  └─ UserConstants      # User-related constants
│     ├─ context/              # Context holders
│     │  └─ SecurityContextHolder # Security context
│     ├─ domain/               # Core domain objects
│     │  └─ R                  # Unified response wrapper
│     ├─ enums/                # Core enumerations
│     │  └─ UserStatus         # User status enum
│     ├─ exception/            # Exception hierarchy
│     │  ├─ base/
│     │  │  └─ BaseException   # Base exception class
│     │  ├─ auth/              # Authentication exceptions
│     │  │  ├─ NotLoginException
│     │  │  ├─ NotPermissionException
│     │  │  └─ NotRoleException
│     │  ├─ file/              # File handling exceptions
│     │  ├─ user/              # User-related exceptions
│     │  └─ ServiceException   # Business exceptions
│     ├─ utils/                # Utility classes
│     │  ├─ bean/
│     │  │  ├─ BeanUtils       # Bean operations
│     │  │  └─ BeanValidators  # Bean validation
│     │  ├─ file/
│     │  │  ├─ FileUtils       # File operations
│     │  │  └─ ImageUtils      # Image processing
│     │  ├─ poi/
│     │  │  └─ ExcelUtil       # Excel operations
│     │  ├─ uuid/
│     │  │  ├─ IdUtils         # ID generation
│     │  │  └─ UUID            # UUID utilities
│     │  ├─ DateUtils          # Date operations
│     │  ├─ JwtUtils           # JWT handling
│     │  ├─ PageUtils          # Pagination
│     │  ├─ SpringUtils        # Spring context
│     │  └─ StringUtils        # String operations
│     ├─ web/                  # Web layer components
│     │  ├─ controller/
│     │  │  └─ BaseController  # Base controller
│     │  ├─ domain/
│     │  │  ├─ AjaxResult      # Ajax response
│     │  │  ├─ BaseEntity      # Base entity with audit
│     │  │  └─ TreeEntity      # Tree structure entity
│     │  └─ page/
│     │     ├─ PageDomain      # Page request
│     │     └─ TableDataInfo   # Table response
│     └─ xss/                  # XSS protection
│        ├─ Xss                # XSS annotation
│        └─ XssValidator       # XSS validator
│
├─ {company}-common-security/   # 🔐 Security Framework
│  └─ com.{company}.common.security/
│     ├─ annotation/           # Security annotations
│     │  ├─ @InnerAuth         # Internal service auth
│     │  ├─ @RequiresLogin    # Login required
│     │  ├─ @RequiresPermissions # Permission check
│     │  └─ @RequiresRoles    # Role check
│     ├─ aspect/               # Security aspects
│     │  ├─ InnerAuthAspect   # Internal auth AOP
│     │  └─ PreAuthorizeAspect # Authorization AOP
│     ├─ auth/                 # Authentication logic
│     │  ├─ AuthLogic          # Auth business logic
│     │  └─ AuthUtil           # Auth utilities
│     ├─ config/               # Security configuration
│     │  ├─ ApplicationConfig  # App configuration
│     │  └─ WebMvcConfig       # MVC configuration
│     ├─ feign/                # Feign integration
│     │  └─ FeignRequestInterceptor # Token propagation
│     ├─ handler/              # Exception handlers
│     │  └─ GlobalExceptionHandler # Global handler
│     ├─ service/              # Security services
│     │  └─ TokenService       # Token management
│     └─ utils/                # Security utilities
│        └─ SecurityUtils      # Security helpers
│
├─ {company}-common-redis/      # 💾 Cache Framework
│  └─ com.{company}.common.redis/
│     ├─ configure/            # Redis configuration
│     │  ├─ FastJson2JsonRedisSerializer # Serializer
│     │  └─ RedisConfig        # Redis settings
│     └─ service/              # Cache services
│        └─ RedisService       # Redis operations
│
├─ {company}-common-log/        # 📝 Logging Framework
│  └─ com.{company}.common.log/
│     ├─ annotation/           # Log annotations
│     │  └─ @Log               # Operation logging
│     ├─ aspect/               # Log aspects
│     │  └─ LogAspect          # Log AOP
│     ├─ enums/                # Log enums
│     │  ├─ BusinessStatus     # Business status
│     │  ├─ BusinessType       # Business type
│     │  └─ OperatorType       # Operator type
│     └─ service/              # Log services
│        └─ AsyncLogService    # Async logging
│
├─ {company}-common-datascope/  # 🔒 Data Permission
│  └─ com.{company}.common.datascope/
│     ├─ annotation/
│     │  └─ @DataScope         # Data scope control
│     └─ aspect/
│        └─ DataScopeAspect    # Data permission AOP
│
├─ {company}-common-datasource/ # 🗄️ Multi-DataSource
│  └─ com.{company}.common.datasource/
│     └─ annotation/
│        ├─ @Master            # Master database
│        └─ @Slave             # Slave database
│
├─ {company}-common-seata/      # 🔄 Distributed Transaction
│  └─ com.{company}.common.seata/
│     └─ config/               # Seata configuration
│
├─ {company}-common-swagger/    # 📚 API Documentation
│  └─ com.{company}.common.swagger/
│     └─ config/
│        ├─ Knife4jAutoConfiguration # Knife4j config
│        ├─ SpringDocAutoConfiguration # OpenAPI 3
│        └─ properties/
│           └─ SpringDocProperties # Doc properties
│
└─ {company}-common-sensitive/  # 🛡️ Data Masking
   └─ com.{company}.common.sensitive/
      ├─ annotation/
      │  └─ @Sensitive         # Sensitive data mark
      ├─ enums/
      │  └─ DesensitizedType   # Masking types
      └─ utils/
         └─ DesensitizedUtil   # Masking utilities
```

---

## 📂 PART 2: BUSINESS MICROSERVICE ARCHITECTURE

### Required Package Structure for Each Microservice
Every business microservice MUST follow this structure under `com.{company}.{module}/`:

```
com.{company}.{module}/
├─ controller/                  # REST API Layer
│  ├─ admin/                   # Admin endpoints
│  │  └─ {Entity}AdminController
│  ├─ app/                     # User endpoints
│  │  └─ {Entity}Controller
│  └─ feign/                   # Feign client interfaces
│     └─ {Entity}FeignController
│
├─ service/                    # Business Logic Layer
│  ├─ I{Entity}Service         # Service interface
│  ├─ impl/
│  │  └─ {Entity}ServiceImpl   # Service implementation（QueryWrapper & LambdaQueryWrapper）
│  └─ remote/
│     └─ Remote{Module}Service # Remote service calls
│
├─ mapper/                     # Data Access Layer
│  └─ {Entity}Mapper           # MyBatis mapper(may not need?)
│
├─ domain/                     # Domain Models（@Builder）
│  ├─ entity/                  # Database entities（@Builder）
│  │  └─ {Entity}              # Extends BaseEntity（@Builder）
│  ├─ dto/                     # Data transfer objects（@Builder）
│  │  ├─ {Entity}DTO          # Basic DTO
│  │  ├─ {Entity}AddDTO       # Create DTO
│  │  ├─ {Entity}UpdateDTO    # Update DTO
│  │  └─ {Entity}QueryDTO     # Query DTO
│  ├─ vo/                      # View objects（@Builder）
│  │  ├─ {Entity}VO           # Basic view
│  │  ├─ {Entity}DetailVO     # Detailed view
│  │  └─ {Entity}ListVO       # List view
│  └─ bo/                      # Business objects（@Builder）
│     └─ {Entity}BO           # Internal business object
│
├─ enums/                      # Module enumerations
│  ├─ {Entity}Status
│  └─ {Entity}Type
│
├─ constant/                   # Module constants
│  └─ {Module}Constants
│
├─ handler/                    # Event handlers
│  └─ {Entity}EventHandler
│
├─ listener/                   # Message listeners
│  └─ {Entity}MessageListener
│
├─ task/                       # Scheduled tasks
│  └─ {Entity}Task
│
├─ aspect/                     # Module aspects
│  └─ {Module}LogAspect
│
├─ utils/                      # Module utilities
│  └─ {Module}Utils
│
└─ config/                     # Module configuration
   └─ {Module}Config
```

### Resources Structure
```
src/main/resources/
├─ mapper/                     # MyBatis XML files(may not need?)
│  └─ {Entity}Mapper.xml（尽可能使用mybatisplus，尽量少写这些，尽可能易于维护）
├─ i18n/                       # Internationalization
│  └─ messages.properties
├─ application.yml             # Main configuration
├─ application-{env}.yml       # Environment configs
├─ bootstrap.yml               # Bootstrap config
└─ logback-spring.xml          # Logging config
```

---

## 📕 PART 3: MANDATORY DEVELOPMENT RULES (MUST)

### Modern Development Compliance Rules

#### Rule 1: YAGNI (You Aren't Gonna Need It)
- **MUST NOT** implement features not currently required
- **MUST NOT** add abstraction layers for "future possibilities"
- **MUST NOT** create inheritance hierarchies exceeding 3 levels
- **MUST** remove all unused code

#### Rule 2: DRY (Don't Repeat Yourself)
- **MUST NOT** copy-paste code blocks exceeding 3 lines
- **MUST** extract repeated logic into separate methods/components
- **MUST** use constants for repeated literals
- **MUST NOT** hardcode identical business rules in multiple locations

#### Rule 3: Use Records for Immutable Data
- **MUST** use Records for all DTOs in Java 14+
- **MUST** use Records for API request/response objects
- **MUST** use Records for configuration classes
- **MUST NOT** create getters/setters for pure data classes

#### Rule 4: Fail Fast Principle
- **MUST** validate all parameters at method entry
- **MUST** validate invariants in constructors
- **MUST NOT** return null, use Optional instead
- **MUST NOT** silently ignore caught exceptions

#### Rule 5: Code Complexity Limits
- **MUST** keep method length ≤ 20 lines
- **MUST** maintain cyclomatic complexity ≤ 5
- **MUST** keep class files ≤ 200 lines
- **MUST** limit parameters to ≤ 3

### Framework Integration Requirements

#### Rule 6: Common Module Usage
- **MUST** extend `BaseEntity` for all entities
- **MUST** use `R<T>` or `AjaxResult` for API responses
- **MUST** extend `BaseController` for common functionality
- **MUST** use framework exceptions (`ServiceException`, `BaseException`)

#### Rule 7: Security Implementation
- **MUST** use `@RequiresPermissions` for authorization
- **MUST** implement `@InnerAuth` for internal service calls
- **MUST** use `SecurityUtils` for user context
- **MUST** apply `@DataScope` for data permissions

#### Rule 8: Logging Standards
- **MUST** use `@Log` annotation for operation logging
- **MUST** specify `BusinessType` and `OperatorType`
- **MUST** use structured logging with correlation IDs
- **MUST** implement async logging for performance

#### Rule 9: Data Validation
- **MUST** use `@Validated` on controllers
- **MUST** implement `BeanValidators` for complex validation
- **MUST** use `@Xss` annotation for XSS prevention
- **MUST** validate with framework's validation groups

#### Rule 10: Cache Management
- **MUST** use `RedisService` for all caching
- **MUST** follow key pattern: `{module}:{entity}:{id}`
- **MUST** implement cache warm-up for critical data
- **MUST** handle cache avalanche scenarios

---

## 📘 PART 4: RECOMMENDED PRACTICES (SHOULD)

### Design Principles

#### Rule 11: Single Responsibility Principle
- **SHOULD** have one class responsible for one domain
- **SHOULD** have one method do one thing
- **SHOULD NOT** mix business logic and infrastructure
- **SHOULD** separate validation, calculation, and persistence

#### Rule 12: Dependency Inversion Principle
- **SHOULD** depend on interfaces not implementations
- **SHOULD** use dependency injection
- **SHOULD NOT** directly instantiate concrete classes
- **SHOULD** ensure high-level modules are independent

#### Rule 13: Immutability First
- **SHOULD** prioritize immutable objects
- **SHOULD** use final modifier for fields
- **SHOULD** return defensive copies
- **SHOULD NOT** provide setters unless necessary

#### Rule 14: Composition Over Inheritance
- **SHOULD** use composition for extension
- **SHOULD** use Strategy pattern over Template Method
- **SHOULD NOT** create deep inheritance
- **SHOULD** prefer interfaces for contracts

#### Rule 15: Single Source of Truth
- **SHOULD** define data in only one place
- **SHOULD NOT** duplicate data storage
- **SHOULD** use references over copying
- **SHOULD** centralize configuration

### Technical Practices

#### Rule 16: Resilience Patterns
- **SHOULD** implement circuit breakers with Sentinel
- **SHOULD** use retry mechanisms with exponential backoff
- **SHOULD** implement bulkheads for resource isolation
- **SHOULD** handle timeouts gracefully

#### Rule 17: Observability
- **SHOULD** use structured logging with correlation IDs
- **SHOULD** implement distributed tracing
- **SHOULD** export metrics to monitoring systems
- **SHOULD** create custom business metrics

#### Rule 18: Testing Strategy
- **SHOULD** achieve 80% unit test coverage
- **SHOULD** write integration tests for APIs
- **SHOULD** use Testcontainers for database tests
- **SHOULD** implement contract testing

#### Rule 19: Performance Optimization
- **SHOULD** use database connection pooling
- **SHOULD** implement pagination for large datasets
- **SHOULD** use async processing for heavy operations
- **SHOULD** optimize N+1 query problems

---

## 📗 PART 5: OPTIONAL ENHANCEMENTS (MAY)

#### Rule 20: Advanced Patterns
- **MAY** implement CQRS for complex domains
- **MAY** use Event Sourcing for audit
- **MAY** apply Domain Events for decoupling
- **MAY** implement Saga pattern for transactions

#### Rule 21: Cloud Native Features
- **MAY** implement auto-scaling policies
- **MAY** use service mesh (Istio/Linkerd)
- **MAY** implement blue-green deployments
- **MAY** use feature flags for gradual rollouts

---

## 🔴 PART 6: FORBIDDEN PRACTICES (MUST NOT)

### Code Quality Red Lines

#### Rule 22: Dangerous Practices
- **MUST NOT** use `System.out.println` in production
- **MUST NOT** hardcode passwords or keys
- **MUST NOT** disable compiler warnings
- **MUST NOT** use `@SuppressWarnings("all")`

#### Rule 23: Bad Code Patterns
- **MUST NOT** catch `Exception` or `Throwable`
- **MUST NOT** submit untested code
- **MUST NOT** comment out code instead of deleting
- **MUST NOT** use magic numbers without constants
- **MUST NOT** create circular dependencies
- **MUST NOT** ignore framework validation

#### Rule 24: Security Violations
- **MUST NOT** bypass security annotations
- **MUST NOT** expose sensitive data in logs
- **MUST NOT** trust user input without validation
- **MUST NOT** use weak encryption algorithms
- **MUST NOT** expose internal IDs in APIs
- **MUST NOT** store passwords in plain text

#### Rule 25: Architecture Violations
- **MUST NOT** make database calls from controllers
- **MUST NOT** implement business logic in entities
- **MUST NOT** create god classes/services
- **MUST NOT** violate layer boundaries
- **MUST NOT** use synchronous calls for long operations
- **MUST NOT** create tight coupling between services

---

## 🎯 PART 7: IMPLEMENTATION EXAMPLES

### Controller Implementation
```java
@RestController
@RequestMapping("/api/v1/{module}")
@Tag(name = "{Entity} Management")
@RequiredArgsConstructor
@Validated
public class {Entity}Controller extends BaseController {
    
    private final I{Entity}Service {entity}Service;
    
    @GetMapping("/{id}")
    @RequiresPermissions("{module}:{entity}:query")
    @Log(title = "Query {Entity}", businessType = BusinessType.QUERY)
    public R<{Entity}DetailVO> getInfo(@PathVariable Long id) {
        return R.ok({entity}Service.getInfo(id));
    }
    
    @PostMapping
    @RequiresPermissions("{module}:{entity}:add")
    @Log(title = "Add {Entity}", businessType = BusinessType.INSERT)
    public R<Void> add(@Validated @RequestBody {Entity}AddDTO dto) {
        return toAjax({entity}Service.add(dto));
    }
    
    @PutMapping
    @RequiresPermissions("{module}:{entity}:edit")
    @Log(title = "Update {Entity}", businessType = BusinessType.UPDATE)
    public R<Void> edit(@Validated @RequestBody {Entity}UpdateDTO dto) {
        return toAjax({entity}Service.update(dto));
    }
    
    @DeleteMapping("/{ids}")
    @RequiresPermissions("{module}:{entity}:remove")
    @Log(title = "Delete {Entity}", businessType = BusinessType.DELETE)
    public R<Void> remove(@PathVariable Long[] ids) {
        return toAjax({entity}Service.deleteByIds(Arrays.asList(ids)));
    }
    
    @GetMapping("/list")
    @RequiresPermissions("{module}:{entity}:list")
    public TableDataInfo list({Entity}QueryDTO query) {
        startPage();
        List<{Entity}ListVO> list = {entity}Service.selectList(query);
        return getDataTable(list);
    }
}
```

### Service Implementation
```java
@Service
@RequiredArgsConstructor
@Slf4j
public class {Entity}ServiceImpl implements I{Entity}Service {
    
    private final {Entity}Mapper {entity}Mapper;
    private final RedisService redisService;
    
    @Override
    @DataScope(deptAlias = "d", userAlias = "u")
    public List<{Entity}ListVO> selectList({Entity}QueryDTO query) {
        // Data permission applied automatically
        return {entity}Mapper.selectListByQuery(query);
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean add({Entity}AddDTO dto) {
        // Validate business rules
        validateBusinessRules(dto);
        
        // Convert DTO to entity
        {Entity} entity = BeanUtils.toBean(dto, {Entity}.class);
        
        // Save to database
        boolean result = {entity}Mapper.insert(entity) > 0;
        
        // Clear cache
        redisService.deleteObject(getCacheKey(entity.getId()));
        
        // Publish event
        SpringUtils.getApplicationContext().publishEvent(
            new {Entity}CreatedEvent(entity)
        );
        
        return result;
    }
    
    @Override
    public {Entity}DetailVO getInfo(Long id) {
        // Try cache first
        String cacheKey = getCacheKey(id);
        {Entity}DetailVO cached = redisService.getCacheObject(cacheKey);
        if (cached != null) {
            return cached;
        }
        
        // Query database
        {Entity} entity = {entity}Mapper.selectById(id);
        if (entity == null) {
            throw new ServiceException("{Entity} not found");
        }
        
        // Convert and cache
        {Entity}DetailVO vo = BeanUtils.toBean(entity, {Entity}DetailVO.class);
        redisService.setCacheObject(cacheKey, vo, 30, TimeUnit.MINUTES);
        
        return vo;
    }
    
    private String getCacheKey(Long id) {
        return CacheConstants.{MODULE}_KEY + id;
    }
    
    private void validateBusinessRules({Entity}AddDTO dto) {
        // Implement business validation
        if (StringUtils.isEmpty(dto.getName())) {
            throw new ServiceException("Name cannot be empty");
        }
    }
}
```

### Entity Definition
```java
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("{module}_{entity}")
public class {Entity} extends BaseEntity {
    
    @Serial
    private static final long serialVersionUID = 1L;
    
    @TableId(type = IdType.ASSIGN_ID)
    private Long id;
    
    @TableField("name")
    @NotBlank(message = "Name cannot be empty")
    @Size(max = 100, message = "Name length cannot exceed 100")
    private String name;
    
    @TableField("status")
    private String status;
    
    @TableField("dept_id")
    private Long deptId;
    
    @TableField("user_id")
    private Long userId;
    
    @TableLogic
    @TableField("del_flag")
    private String delFlag;
}
```

---

## 📋 PART 8: CONFIGURATION TEMPLATES

### Application Configuration
```yaml
spring:
  application:
    name: {company}-{module}
  
  # Data source
  datasource:
    type: com.zaxxer.hikari.HikariDataSource
    driver-class-name: com.mysql.cj.jdbc.Driver
    url: jdbc:mysql://localhost:3306/{module}?useUnicode=true
    username: ${DB_USERNAME:root}
    password: ${DB_PASSWORD:password}
  
  # Redis
  redis:
    host: ${REDIS_HOST:localhost}
    port: ${REDIS_PORT:6379}
    password: ${REDIS_PASSWORD:}
    database: ${REDIS_DB:0}
  
  # Cloud config
  cloud:
    nacos:
      discovery:
        server-addr: ${NACOS_SERVER:localhost:8848}
      config:
        server-addr: ${NACOS_SERVER:localhost:8848}
        file-extension: yml

# MyBatis Plus
mybatis-plus:
  mapper-locations: classpath*:mapper/**/*Mapper.xml
  type-aliases-package: com.{company}.{module}.domain.entity
  configuration:
    map-underscore-to-camel-case: true
    cache-enabled: false
    log-impl: org.apache.ibatis.logging.stdout.StdOutImpl

# Security configuration
security:
  # Token configuration
  token:
    header: Authorization
    prefix: Bearer
    secret: ${JWT_SECRET:defaultSecret}
    expireTime: 30

# Logging
logging:
  level:
    com.{company}: debug
  pattern:
    console: "%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n"

# API Documentation
springdoc:
  api-docs:
    enabled: true
    path: /v3/api-docs
  swagger-ui:
    enabled: true
    path: /swagger-ui.html
```

### Maven Dependencies
```xml
<dependencies>
    <!-- Common modules -->
    <dependency>
        <groupId>com.{company}</groupId>
        <artifactId>{company}-common-core</artifactId>
    </dependency>
    <dependency>
        <groupId>com.{company}</groupId>
        <artifactId>{company}-common-security</artifactId>
    </dependency>
    <dependency>
        <groupId>com.{company}</groupId>
        <artifactId>{company}-common-redis</artifactId>
    </dependency>
    <dependency>
        <groupId>com.{company}</groupId>
        <artifactId>{company}-common-log</artifactId>
    </dependency>
    <dependency>
        <groupId>com.{company}</groupId>
        <artifactId>{company}-common-swagger</artifactId>
    </dependency>
    
    <!-- Spring Boot -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-validation</artifactId>
    </dependency>
    
    <!-- Database -->
    <dependency>
        <groupId>com.baomidou</groupId>
        <artifactId>mybatis-plus-boot-starter</artifactId>
    </dependency>
    <dependency>
        <groupId>com.mysql</groupId>
        <artifactId>mysql-connector-j</artifactId>
    </dependency>
    
    <!-- Cloud -->
    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-starter-openfeign</artifactId>
    </dependency>
    <dependency>
        <groupId>com.alibaba.cloud</groupId>
        <artifactId>spring-cloud-starter-alibaba-nacos-discovery</artifactId>
    </dependency>
</dependencies>
```

---

## 🚀 PART 9: IMPLEMENTATION CHECKLIST

### Development Checklist
✅ **Framework Integration**
- [ ] Extends BaseEntity for entities
- [ ] Uses R<T> for API responses
- [ ] Implements security annotations
- [ ] Integrates with RedisService

✅ **Code Quality**
- [ ] Methods ≤ 20 lines
- [ ] Classes ≤ 200 lines
- [ ] No code duplication
- [ ] Proper exception handling

✅ **Security**
- [ ] Permission annotations
- [ ] Data scope control
- [ ] XSS prevention
- [ ] Input validation

✅ **Testing**
- [ ] Unit tests (80% coverage)
- [ ] Integration tests
- [ ] API tests
- [ ] Performance tests

✅ **Documentation**
- [ ] API documentation
- [ ] Code comments
- [ ] README file
- [ ] Deployment guide

✅ **Operations**
- [ ] Health checks
- [ ] Metrics exposure
- [ ] Log aggregation
- [ ] Alert configuration

---

## 📝 FINAL COMPLIANCE STATEMENT

This architecture specification ensures:
1. **Consistency** - Uniform structure across all services
2. **Security** - Built-in security at every layer
3. **Performance** - Optimized with caching and async
4. **Maintainability** - Clean code with clear boundaries
5. **Scalability** - Cloud-native design patterns
6. **Observability** - Comprehensive logging and monitoring

**ALL code MUST strictly comply with these specifications. Non-compliance will result in immediate rejection during code review.**

**Version**: 3.0.0  
**Framework**: {company}-common  
**Compliance Level**: MANDATORY  
**Last Updated**: 2025