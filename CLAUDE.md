# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is the **XiangYuPai-Doc** repository - a centralized documentation hub for the XiangYuPai (享遇派) project, a microservices-based social discovery and local services platform.

### Related Repositories

This workspace includes three interconnected projects:
- **XiangYuPai-Doc** (current) - Documentation repository
- **XiangYuPai-RNExpoAPP** - React Native/Expo mobile application
- **RuoYi-Cloud-Plus** - Spring Cloud microservices backend

## Project Architecture

### Backend: Spring Cloud Microservices

**Technology Stack:**
- Java 21 (LTS)
- Spring Boot 3.2.0
- Spring Cloud 2023.0.3
- Spring Cloud Alibaba 2023.0.1.2
- MyBatis Plus 3.5.7
- MySQL 8.0+ with spatial indexing
- Redis 7.0+
- Nacos 2.x (service registry & config center)

**Microservices Architecture:**
- **Gateway**: Port 8080 - API Gateway
- **Auth**: Port 8081 - Authentication service
- **xypai-user**: Port 9401 - User service
- **xypai-content**: Port 9402 - Content service (discovery/feed)
- **xypai-trade**: Port 9403 - Transaction/commerce service
- **xypai-chat**: Port 9404 - Chat/messaging service
- **xypai-file**: Port 9405 - File storage service

**Key Backend Patterns:**
- 4-layer architecture: Controller → Service → Mapper → Entity
- Separate endpoints: `/admin/`, `/app/`, `/feign/` for different clients
- DTO/VO pattern: `{Entity}AddDTO`, `{Entity}UpdateDTO`, `{Entity}QueryDTO` for requests; `{Entity}DetailVO`, `{Entity}ListVO` for responses
- Statistics separation: Independent stats tables (UserStats, ContentStats) + Redis caching
- Spatial indexing: MySQL POINT/POLYGON types for location-based queries

### Frontend: React Native + Expo

**Technology Stack:**
- React Native with Expo
- TypeScript
- Features-based modular architecture (see [前端写页面/FRONTEND_ARCHITECTURE_STANDARD.md](前端写页面/FRONTEND_ARCHITECTURE_STANDARD.md))

**Architecture Principles:**
- **Features modularity**: `src/features/{ModuleName}/` for business modules
- **Pseudo-page components**: Components directly under pages, not in intermediate `components/` folders
- **Two organization modes**:
  - Flat (≤2 UI layers, ≤3 features): Simple components
  - Nested (≥3 UI layers, ≥4 features): Complex components with functional areas
- **Complete structure**: Every component has `index`, `types`, `constants`, `README.md` + functional files as needed
- **YAGNI + MVP**: Complete architecture structure, but minimal code implementation

## Database Architecture

### Current State (MVP)

11 core tables using JSON for flexible metadata storage:
- Users, Content, Comments, Messages, etc.
- `metadata` JSONB fields for extensible data

### Target State (Production)

60+ normalized tables with:
- Full field expansion (no JSON)
- Separate statistics tables
- Spatial indexes (POINT/POLYGON for geo queries)
- Message sharding (256 tables)
- Partitioned tables for high-volume data

### Migration Strategy

- **Dual-write**: Maintain both old and new fields during transition
- **Gray release**: 5% → 20% → 50% → 100% traffic
- **Data validation**: Scheduled tasks to sync and verify data

### v7.1 Database Enhancements

**5 enhanced tables with 114 new fields:**

1. **UserBehavior** (+16 fields): Session tracking, scroll depth, conversion analysis, date partitioning
2. **SearchHistory** (+10 fields): Normalized keywords, click position, satisfaction detection
3. **HotSearch** (+15 fields): Trend scoring, ranking system, rising indicators
4. **UserPreference** (+15 fields): Location memory (POINT), privacy settings, notification preferences
5. **City** (+15 fields): Center location (POINT), city boundaries (POLYGON), service status

**Performance improvements:**
- Spatial queries: 10x faster (500ms → 50ms)
- Hot search: 100x faster (200ms → 2ms)
- User preferences: 50x faster (100ms → 2ms)
- Async writes: Non-blocking behavior tracking

## Key Documentation Files

### Task Management
- [📋_任务管理文档.md](📋_任务管理文档.md) - Current development tasks, progress tracking, and implementation checklists

### Technical Standards
- [启动/AAAAAA_TECH_STACK_REQUIREMENTS.md](启动/AAAAAA_TECH_STACK_REQUIREMENTS.md) - Complete tech stack specification (backend + database + v7.1 enhancements)
- [前端写页面/FRONTEND_ARCHITECTURE_STANDARD.md](前端写页面/FRONTEND_ARCHITECTURE_STANDARD.md) - Enterprise-level frontend architecture (3-tier: Project → Page → Module)

### API Documentation
- [Content/接口对接前端页面映射.md](Content/接口对接前端页面映射.md) - Frontend-backend API mapping for content/discovery modules
- Content module has comprehensive API documentation (in backend repo)

### Configuration
- `nacos/` - Nacos configuration files for all microservices
  - Application configs: `xypai-*.yml`
  - Common configs: `application-common.yml`, `datasource.yml`
  - Gateway config: `ruoyi-gateway.yml`

### PlantUML Documentation Standards
- [TXT/PlantUML编写规范指南.md](TXT/PlantUML编写规范指南.md) - Standards for architecture diagrams
- [TXT/PlantUML更新说明_v5.0.md](TXT/PlantUML更新说明_v5.0.md) - PlantUML template updates

### Module Architecture Designs
- `TXT/页面设计+流程文档/` - Detailed architecture docs for each app module:
  - Login module
  - Homepage/Discovery
  - Personal profile
  - Messages
  - Activity center

## Development Workflow

### Backend Development

**Mandatory 4-layer architecture:**
```
Controller (app/admin/feign)
  ↓
Service (interface + impl)
  ↓
Mapper (MyBatis Plus LambdaQueryWrapper preferred)
  ↓
Entity (BaseEntity + @TableName)
```

**Required for all entities:**
- Extend `BaseEntity` (created_at, updated_at)
- Use `@TableId(type = IdType.ASSIGN_ID)` for snowflake IDs
- Use `@TableLogic` for soft delete
- Use `@Version` for optimistic locking
- Use `@Builder` pattern

**API Standards:**
- RESTful URLs: `/api/v{version}/{module}/{resource}`
- Response wrapper: `R<T>` for all responses
- Validation: `@Validated` + Jakarta Validation annotations
- Documentation: `@Tag`, `@Operation` (Knife4j/Swagger)
- Security: `@RequiresPermissions` for protected endpoints, `@InnerAuth` for internal calls

**Performance requirements:**
- P95 response time: < 300ms
- P99 response time: < 500ms
- Pagination required for lists
- Redis caching for hot data (30min TTL)
- Async processing for expensive operations

### Frontend Development

**Architecture decision tree:**

1. **Project level**: Use Features modular architecture (`src/features/{ModuleName}/`)
2. **Page level**: Choose based on complexity
   - Simple (≤2 UI layers, ≤3 features) → Flat architecture
   - Complex (≥3 UI layers, ≥4 features) → Nested architecture with functional areas
3. **Large modules (1000+ lines)**: Use 13-layer enterprise architecture

**Required files for every component:**
- `index.[ext]` - Main component file
- `types.[ext]` - TypeScript type definitions
- `constants.[ext]` - Constants and configuration
- `README.md` - Component documentation

**Functional files (as needed):**
- `use{ComponentName}.[ext]` - State management
- `on{ComponentName}{Action}.[ext]` - Event handlers
- `navigateTo{Target}.[ext]` - Navigation logic
- `api{ComponentName}{Action}.[ext]` - API calls
- `process{ComponentName}{Data}.[ext]` - Data processing

**Performance optimization:**
- All components: `React.memo`
- Lists: Virtual scrolling (FlatList)
- Images: Lazy loading with placeholders
- Network: Request caching and debouncing

### Git Standards

**Branch strategy:**
- `main` - Production (protected)
- `develop` - Development
- `feature/*` - Feature branches
- `hotfix/*` - Emergency fixes

**Commit message format:**
```
<type>(<scope>): <subject>

Types: feat, fix, refactor, perf, docs, test
Example: feat(content): 添加内容发布功能
```

## Common Development Tasks

### Working with Documentation

**File organization:**
- Use emoji prefixes for quick identification:
  - 📄 Complete documentation
  - ⚡ Quick reference
  - 🧪 Test guides
  - 📚 Index/navigation
  - 📦 Data/config files
  - 📋 Checklists
  - ✅ Completion reports

**PlantUML diagrams:**
- Follow standards in `TXT/PlantUML编写规范指南.md`
- Use templates from `UI转文档/纯结构架构图标准模板.md`

### Updating Task Documentation

The [📋_任务管理文档.md](📋_任务管理文档.md) tracks all development tasks:
- Mark tasks as `[x]` when completed
- Update progress percentages
- Add new tasks under appropriate sections
- Document blockers in "待解决问题"

### Configuration Management

**Nacos configs:**
- Service-specific: `xypai-{service}.yml`
- Common settings: `application-common.yml`
- Database: `datasource.yml`
- Use environment variables for sensitive data: `${DB_USER:root}`

**Upload to Nacos:**
```bash
cd nacos
# Windows
上传配置到Nacos.bat

# Linux/Mac
./upload_xypai_content_config.sh
```

## Critical Principles

### Backend (8 Core Rules)

1. **4-layer architecture**: Controller → Service → Mapper → Entity (no shortcuts)
2. **Statistics separation**: Independent stats tables + Redis (not in business tables)
3. **Spatial indexing**: Use POINT/POLYGON + SPATIAL INDEX for location queries
4. **MyBatis Plus first**: Use LambdaQueryWrapper, minimize XML mappers
5. **Partitioned tables**: For high-volume data (UserBehavior, SearchHistory)
6. **Async operations**: Message queues for expensive operations (tracking, notifications)
7. **Security annotations**: `@RequiresPermissions`, `@InnerAuth`, `@Log` on all endpoints
8. **Never**: Cross-service database access, hardcoded configs, SELECT *, catch without handling

### Frontend (12 Core Rules)

1. **Features modularity**: Business modules in `src/features/{ModuleName}/`
2. **No components/ layer**: Components directly under pages (pseudo-page components)
3. **Complete structure**: All components have index/types/constants/README
4. **Complexity-based architecture**: Choose flat vs nested based on component complexity
5. **Explicit naming**: `use*`, `on*`, `navigateTo*`, `api*` - no generic names
6. **Single responsibility**: Each file handles one concern
7. **YAGNI + MVP**: Complete structure, minimal implementation, iterate
8. **Type everything**: TypeScript strict mode, no implicit any
9. **Memo all components**: React.memo for performance
10. **Virtual lists**: FlatList for any scrollable list
11. **Architecture complete ≠ code complex**: Full structure, simple code
12. **Never**: any type, class components, hardcoded values, files >50 lines without splitting

## Important Notes

- **This is a documentation repo**: The actual code is in XiangYuPai-RNExpoAPP (frontend) and RuoYi-Cloud-Plus (backend)
- **Multi-repo workspace**: Use the workspace file to navigate between related projects
- **Chinese language**: Most documentation is in Chinese; preserve this when updating
- **PlantUML diagrams**: Many architecture docs use PlantUML; follow the established standards
- **Active development**: Check [📋_任务管理文档.md](📋_任务管理文档.md) for current sprint tasks

## Monitoring & Operations

**Health checks:** All services expose `/actuator/health`, `/actuator/metrics`

**Logging standards:**
- Use `@Slf4j`, never `System.out.println`
- Levels: ERROR (system errors), WARN (business exceptions), INFO (key operations), DEBUG (dev only)

**Performance SLA:**
- System availability: >99.9%
- Concurrent capacity: Login 1000 QPS, Content lists 2000 QPS
- Database queries: <200ms (lists), <100ms (details)

## Environment Setup

**Required software:**
- JDK 21
- Maven 3.8+
- MySQL 8.0+ (with spatial extension enabled)
- Redis 7.0+
- Nacos 2.x
- Node.js (for frontend)

**Docker quick start:**
```bash
cd docker
docker-compose up -d mysql redis nacos
```

**Access points:**
- Gateway: http://localhost:8080
- Nacos: http://localhost:8848/nacos
- API docs: http://localhost:{service-port}/doc.html
