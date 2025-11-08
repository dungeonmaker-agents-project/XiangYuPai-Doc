# 🏗️ 前端企业级架构标准（综合版）

> **适用范围**: React / React Native / Vue / 通用前端项目  
> **架构等级**: Enterprise  
> **版本**: v3.0  
> **更新日期**: 2025-11-07

**📌 本文档整合**:
- ✅ 13层企业级模块架构（大型模块内部组织）
- ✅ 伪页面组件架构（组件级别组织）
- ✅ Features模块化架构（项目级别组织）
- ✅ 完整结构标准（文件组织规范）
- ✅ YAGNI + MVP实施原则

**📖 阅读时间**: 30分钟  
**📋 页数**: 约40页

---

## 📑 目录

### 第一部分：架构总览
1. [核心理念](#核心理念-4大设计原则)
2. [三层架构体系](#三层架构体系)
3. [架构决策树](#架构决策树)

### 第二部分：项目级架构（Features）
4. [Features模块化架构](#features模块化架构)
5. [模块组织规范](#模块组织规范)

### 第三部分：页面级架构（伪页面组件）
6. [伪页面组件架构](#伪页面组件架构)
7. [混合架构模式](#混合架构模式-扁平化-vs-嵌套化)
8. [组件复杂度判断](#组件复杂度判断矩阵)

### 第四部分：模块级架构（13层结构）
9. [13层企业级架构](#13层企业级模块架构)
10. [各层详细规范](#各层详细规范)

### 第五部分：通用规范
11. [文件命名规范](#文件命名规范体系)
12. [完整结构标准](#完整结构标准)
13. [代码实施原则](#代码实施原则-yagni--mvp)
14. [性能优化策略](#性能优化策略)

### 第六部分：实施指南
15. [Agent执行指令](#agent-执行指令)
16. [开发检查清单](#开发检查清单)
17. [核心原则总结](#核心原则-记住这20条)

---

## 🎯 核心理念（4大设计原则）

### 1. 框架无关性 (Framework Agnostic)
- 架构思想不依赖特定的技术栈
- 命名规范和文件组织方式通用
- 可在 React / React Native / Vue / Angular 中实现

### 2. 具名化原则 (Explicit Naming)
- 所有文件都使用具有明确含义的名称
- 文件名直接反映其功能和职责
- 避免使用模糊的通用名称（如 `utils.ts`, `helpers.ts`）

### 3. 单一职责原则 (Single Responsibility)
- 每个文件只负责一个具体的功能
- 状态管理、事件处理、导航逻辑各司其职
- 便于单独测试、维护和复用

### 4. 自包含原则 (Self-Contained)
- 每个模块包含其所有相关代码
- 类型定义、常量、逻辑都在模块内部
- 减少跨模块依赖，提高内聚性

---

## 🏛️ 三层架构体系

```
前端项目架构体系（三层递进）
│
├─ 🏢 项目层 - Features模块化架构
│   ├─ 目的：组织大型业务功能模块
│   ├─ 范围：整个项目的顶层结构
│   ├─ 示例：AuthModule, Homepage, Messages, Profile
│   └─ 组织：src/features/{ModuleName}/
│
├─ 📄 页面层 - 伪页面组件架构
│   ├─ 目的：组织页面级功能组件
│   ├─ 范围：单个页面内的组件组织
│   ├─ 示例：MainPage, DetailPage, UserCard, SearchBar
│   ├─ 组织：src/features/{ModuleName}/{PageName}/{ComponentName}/
│   └─ 模式：扁平化（简单组件）/ 嵌套化（复杂组件）
│
└─ 🧩 模块层 - 13层企业级架构
    ├─ 目的：组织单个大型模块/页面的内部结构
    ├─ 范围：1000-9000行的单文件模块
    ├─ 示例：复杂的页面主文件、大型组件
    ├─ 组织：按13层职责分离
    └─ 层级：Infrastructure → Types → Services → Hooks → Components → Logic
```

---

## 🎯 架构决策树

```
架构选择决策流程
│
├─ 【Level 1】项目级别决策
│   ├─ 问题：如何组织整个项目的业务模块？
│   ├─ 方案：使用 Features 模块化架构
│   └─ 路径：src/features/{ModuleName}/
│
├─ 【Level 2】页面级别决策
│   ├─ 问题：如何组织页面内的组件？
│   ├─ 方案：使用伪页面组件架构
│   ├─ 判断：组件复杂度？
│   │   ├─ UI层次 ≤ 2层，功能 ≤ 3个 → 扁平化架构 🟢
│   │   └─ UI层次 ≥ 3层，功能 ≥ 4个 → 嵌套化架构 🔵
│   └─ 路径：src/features/{ModuleName}/{PageName}/{ComponentName}/
│
└─ 【Level 3】模块级别决策
    ├─ 问题：如何组织大型模块/页面的内部结构？
    ├─ 方案：使用 13层企业级架构
    ├─ 适用：1000行+ 的大型模块/页面
    └─ 结构：13层职责分离（Infrastructure → Export）
```

---

## 🏢 Features模块化架构

### 📍 架构定义

**Features架构**是项目级别的顶层组织方式，将应用按业务功能模块划分，每个模块拥有完整的业务闭环。

### 🌳 标准目录结构

```
src/
├─ features/                                    # Features容器层
│   │
│   ├─ {ModuleName}/                           # 业务功能模块（如 AuthModule）
│   │   ├─ api/                                # 模块API接口
│   │   ├─ config/                             # 模块配置
│   │   ├─ data/                               # 模块数据模型
│   │   ├─ hooks/                              # 模块级Hooks
│   │   ├─ stores/                             # 模块状态管理
│   │   ├─ utils/                              # 模块工具函数
│   │   │
│   │   ├─ {PageName}/                         # 页面（如 MainPage）
│   │   │   ├─ index.[ext]                     # 页面主文件
│   │   │   ├─ types.[ext]                     # 页面类型
│   │   │   ├─ constants.[ext]                 # 页面常量
│   │   │   ├─ hooks/                          # 页面级Hooks
│   │   │   │
│   │   │   ├─ {ComponentName}/                # 伪页面组件（扁平化）
│   │   │   │   ├─ index.[ext]                 # 组件主文件
│   │   │   │   ├─ types.[ext]                 # 组件类型
│   │   │   │   ├─ constants.[ext]             # 组件常量
│   │   │   │   ├─ use{ComponentName}.[ext]    # 状态管理
│   │   │   │   ├─ on{ComponentName}[Action].[ext] # 事件处理
│   │   │   │   └─ [其他功能文件...]
│   │   │   │
│   │   │   └─ {ComplexComponent}/             # 复杂伪页面组件（嵌套化）
│   │   │       ├─ index.[ext]                 # 主组件文件
│   │   │       ├─ types.[ext]                 # 类型定义
│   │   │       ├─ constants.[ext]             # 常量定义
│   │   │       ├─ use{ComplexComponent}.[ext] # 主状态管理
│   │   │       │
│   │   │       ├─ {FunctionalArea1}/          # 功能区域1（子组件）
│   │   │       │   ├─ index.[ext]
│   │   │       │   ├─ types.[ext]
│   │   │       │   └─ [功能文件...]
│   │   │       │
│   │   │       └─ {FunctionalArea2}/          # 功能区域2（子组件）
│   │   │           └─ [子组件文件...]
│   │   │
│   │   ├─ SharedComponents/                   # 模块共享组件
│   │   └─ README.md                           # 模块文档
│   │
│   ├─ {AnotherModule}/                        # 另一个业务模块
│   └─ ...
│
├─ components/                                  # 全局共享组件
│   └─ ui/                                     # UI组件库
│
├─ hooks/                                      # 全局Hooks
├─ stores/                                     # 全局状态管理
├─ utils/                                      # 全局工具函数
├─ constants/                                  # 全局常量
└─ services/                                   # 全局服务
    └─ api/                                    # 全局API
```

### 🎯 模块划分原则

| 原则 | 说明 | 示例 |
|------|------|------|
| **业务完整性** | 模块包含完整的业务闭环 | AuthModule（登录、注册、验证） |
| **职责单一** | 一个模块只负责一个业务领域 | Messages（消息、聊天、通知） |
| **高内聚** | 模块内部功能高度相关 | Profile（资料、编辑、收藏） |
| **低耦合** | 模块间依赖最小化 | 通过API和事件通信 |
| **可替换** | 模块可独立开发和替换 | 可单独测试、发布 |

### 📋 模块必需文件

```
{ModuleName}/
├─ api/                    # ✅ 必需 - 模块API接口
├─ README.md               # ✅ 必需 - 模块文档
├─ config/                 # 🟡 按需 - 模块配置
├─ hooks/                  # 🟡 按需 - 模块级Hooks
├─ stores/                 # 🟡 按需 - 状态管理
├─ utils/                  # 🟡 按需 - 工具函数
└─ SharedComponents/       # 🟡 按需 - 共享组件
```

---

## 🏗️ 伪页面组件架构

### 📍 架构定义

**伪页面组件**是一种灵活的组件组织方式，让组件直接位于页面层级下，拥有页面级别的功能复杂度和架构自主权，成为具有独立功能的"小页面"。

### 🎭 两种组织模式

#### 🟢 **扁平化模式** - 适用于简单组件

```
src/features/{ModuleName}/{PageName}/
├─ {SimpleComponent}/                          # 简单伪页面组件
│   ├─ index.[ext]                             # 主组件文件
│   ├─ types.[ext]                             # 类型定义
│   ├─ constants.[ext]                         # 常量配置
│   ├─ use{ComponentName}.[ext]                # 状态管理
│   ├─ on{ComponentName}[Action].[ext]         # 事件处理
│   ├─ api{ComponentName}[Action].[ext]        # API接口
│   └─ [其他功能文件...]                        # 按完整架构标准组织
```

**适用条件**:
- UI层次 ≤ 2层
- 功能模块 ≤ 3个
- 跨页面复用价值高
- 功能相对独立简单

**示例组件**: `Button`, `Input`, `Card`, `Modal`, `SearchBar`, `UserAvatar`

#### 🔵 **嵌套化模式** - 适用于复杂组件

```
src/features/{ModuleName}/{PageName}/
├─ {ComplexComponent}/                         # 复杂伪页面组件
│   ├─ index.[ext]                             # 主组件文件 - 组合子组件
│   ├─ types.[ext]                             # 类型定义 - 导出所有类型
│   ├─ constants.[ext]                         # 常量定义 - 导出所有常量
│   ├─ use{ComplexComponent}.[ext]             # 主状态管理 - 协调子组件
│   ├─ README.md                               # 组件文档 - 包含子组件说明
│   │
│   ├─ {FunctionalArea1}/                      # 功能区域1（子组件）
│   │   ├─ index.[ext]                         # 区域主文件
│   │   ├─ types.[ext]                         # 区域类型（可选）
│   │   ├─ constants.[ext]                     # 区域常量（可选）
│   │   ├─ use{FunctionalArea1}.[ext]          # 区域状态管理
│   │   ├─ on{FunctionalArea1}[Action].[ext]   # 区域事件处理
│   │   └─ [区域功能文件...]
│   │
│   ├─ {FunctionalArea2}/                      # 功能区域2（子组件）
│   │   └─ [完整的子组件结构...]
│   │
│   └─ {FunctionalArea3}/                      # 功能区域3（子组件）
│       └─ [完整的子组件结构...]
```

**适用条件**:
- UI层次 ≥ 3层
- 功能模块 ≥ 4个
- 有明确的功能区域划分
- 子组件高度内聚
- 主要在特定业务场景中复用

**示例组件**: `UserCard`, `ProductPanel`, `CommentSection`, `MediaPlayer`, `DataTable`

### 🎯 伪页面组件的四大权力

#### 1. **位置权力** - 平等地位
- **直接位于页面下**: `src/features/{ModuleName}/{PageName}/{ComponentName}/`
- **无中间层级**: 移除 `components/` 层级
- **与页面主文件平等**: 处于同一目录层级
- **支持嵌套扩展**: 复杂组件可包含子组件

#### 2. **架构权力** - 完整自主
- **完整架构标准**: 按完整结构组织
- **自主文件组织**: 内部可有完整文件结构
- **独立职责分离**: 状态、事件、数据各司其职
- **嵌套架构决策权**: 根据复杂度选择模式

#### 3. **功能权力** - 业务完整
- **状态管理权**: 自己的 `use{ComponentName}.ts`
- **事件处理权**: 自己的 `on{ComponentName}[Action].ts`
- **数据处理权**: 自己的 `process{ComponentName}[Data].ts`
- **API调用权**: 自己的 `api{ComponentName}[Action].ts`
- **子组件协调权**: 协调管理多个功能区域

#### 4. **扩展权力** - 成长潜力
- **可成长为子页面**: 功能复杂时可扩展
- **独立测试维护**: 可独立单元测试
- **团队协作友好**: 不同开发者独立开发
- **模块化拆分**: 可拆分为多个功能区域

---

## 📊 组件复杂度判断矩阵

### 🟢 扁平化模式标准

| 维度 | 标准 | 说明 |
|------|------|------|
| **UI层次** | ≤ 2层 | 组件内部UI结构相对简单 |
| **功能模块** | ≤ 3个 | 包含的主要功能模块数量较少 |
| **状态复杂度** | 简单 | 状态管理逻辑相对简单 |
| **复用价值** | 高 | 跨页面、跨项目复用价值较高 |
| **独立性** | 强 | 功能相对独立，依赖较少 |

### 🔵 嵌套化模式标准

| 维度 | 标准 | 说明 |
|------|------|------|
| **UI层次** | ≥ 3层 | 组件内部有明确的区域划分 |
| **功能模块** | ≥ 4个 | 包含多个独立的功能区域 |
| **状态复杂度** | 复杂 | 需要协调多个子组件的状态 |
| **复用价值** | 中等 | 主要在特定业务场景中复用 |
| **内聚性** | 强 | 子组件高度内聚，为父组件服务 |

### 🚀 决策流程图

```
组件架构模式选择
│
├─ UI层次 ≤ 2层？
│   ├─ 是 → 功能模块 ≤ 3个？
│   │   ├─ 是 → 🟢 选择扁平化模式
│   │   └─ 否 → 继续评估...
│   └─ 否 → 继续评估...
│
├─ 有明确功能区域划分？
│   ├─ 是 → 子组件高度内聚？
│   │   ├─ 是 → 🔵 选择嵌套化模式
│   │   └─ 否 → 🟢 选择扁平化模式
│   └─ 否 → 🟢 选择扁平化模式
│
└─ 跨页面复用价值高？
    ├─ 是 → 🟢 选择扁平化模式
    └─ 否 → 🔵 选择嵌套化模式
```

---

## 🏗️ 13层企业级模块架构

### 📍 适用场景

- **大型页面主文件**（1000行以上）
- **复杂业务模块**（多功能集成）
- **单文件实现**（不拆分多文件）

### 🌳 架构层级概览

```
企业级模块（1000-9000行）
│
├─ 📦 Layer 1: Infrastructure Foundation (50行)
│   └─ 依赖导入 + 环境配置
│
├─ 🔷 Layer 2: Type System (100行)
│   └─ TypeScript类型定义
│
├─ 🛠️ Layer 3: Core Library (100行)
│   └─ 工具函数 + FP库
│
├─ 🌐 Layer 4: Service Layer (100行)
│   └─ 网络 + 缓存 + 存储
│
├─ 🏪 Layer 5: State Management (100行)
│   └─ 状态管理 + 中间件
│
├─ 🪝 Layer 6: Hooks Ecosystem (150行)
│   └─ 自定义Hooks
│
├─ 🎨 Layer 7: Design System (100行)
│   └─ 设计令牌 + 主题
│
├─ 🧩 Layer 8: Base Components (100行)
│   └─ 原子 + 布局组件
│
├─ 🏗️ Layer 9: Business Components (300行)
│   └─ 分子 + 组织组件
│
├─ 📄 Layer 10: Page Components (100行)
│   └─ 页面级组件
│
├─ 🧠 Layer 11: Business Logic (100行)
│   └─ 业务逻辑 + 规则
│
├─ 🚀 Layer 12: Application Shell (50行)
│   └─ 应用壳 + 错误边界
│
└─ 📤 Layer 13: Export Interface (50行)
    └─ 导出接口
```

---

## 📋 各层详细规范

### Layer 1: Infrastructure Foundation (50行)

**职责**: 导入依赖、环境配置、全局常量

**必须包含**:
- React/RN核心导入
- 第三方库导入（按字母顺序）
- 本地模块导入（按路径深度）
- 环境变量配置
- API端点常量

**注释规范**:
```typescript
// ═══════════════════════════════════════════════════════════
// ▶ SECTION 1: INFRASTRUCTURE FOUNDATION (50 lines)
// ═══════════════════════════════════════════════════════════
```

---

### Layer 2: Type System (100行)

**职责**: 定义所有TypeScript类型

**类型分类**:

| 类型类别 | 用途 | 命名规范 |
|---------|------|---------|
| **Domain Types** | 领域模型 | Entity<T>, ValueObject<T> |
| **Component Props** | 组件属性 | {Component}Props |
| **API Types** | 接口类型 | {Entity}DTO, {Entity}VO |
| **Utility Types** | 工具类型 | DeepPartial<T>, Result<T, E> |

**规范**:
```yaml
类型命名:
  - DTO后缀: 请求对象 (UserLoginDTO)
  - VO后缀: 响应对象 (UserDetailVO)
  - Props后缀: 组件属性 (UserProfileProps)

强制要求:
  ✅ 所有API接口定义类型
  ✅ 所有组件Props定义类型
  ✅ 避免使用any（使用unknown）
  ❌ 禁止隐式any
```

---

### Layer 4: Service Layer (100行)

**职责**: 网络请求、缓存管理、数据持久化

**服务组件**:

| 服务名称 | 核心功能 | 行数 |
|---------|---------|------|
| **NetworkService** | HTTP请求+拦截器+重试 | 40 |
| **CacheManager** | LRU/TTL缓存策略 | 30 |
| **StorageService** | AsyncStorage/SecureStore | 30 |

**规范**:
```yaml
网络请求:
  - 统一错误处理
  - 自动Token注入
  - 失败重试（3次）
  - 超时配置（10s）

缓存策略:
  - 热数据: TTL 30min
  - 温数据: TTL 2h
  - 冷数据: TTL 24h
```

---

### Layer 5: State Management (100行)

**职责**: 全局状态管理、Context提供者、中间件

**状态分类**:

| Store名称 | 管理内容 | 核心状态 |
|----------|---------|---------|
| **UserStore** | 用户信息 | profile, isLogin |
| **AuthStore** | 认证状态 | token, refreshToken |
| **UIStore** | 界面状态 | loading, modal, toast |
| **ConfigStore** | 配置信息 | theme, language, location |

**规范**:
```yaml
状态设计原则:
  ✅ 不可变数据（Immutable）
  ✅ 单向数据流
  ✅ 最小化状态
  ✅ 状态规范化
  ✅ 避免冗余状态
```

---

### Layer 6: Hooks Ecosystem (150行)

**职责**: 封装可复用逻辑、提供统一API

**Hooks分类**:

| Hook分类 | Hook名称 | 核心功能 |
|---------|---------|---------|
| **Data Fetching** | useQuery | 数据查询+缓存 |
| | useMutation | 数据修改+乐观更新 |
| | useInfiniteScroll | 无限滚动加载 |
| **Form** | useForm | 表单管理+校验 |
| **Performance** | useVirtualizer | 虚拟列表 |
| | useDebounce | 防抖 |
| | useThrottle | 节流 |
| **UI** | useGesture | 手势识别 |
| | useAnimation | 动画控制 |

---

### Layer 7: Design System (100行)

**职责**: 定义设计令牌、主题系统、动画预设

**设计令牌**:

| 令牌类别 | 包含内容 |
|---------|---------|
| **Colors** | Primitive/Semantic/Theme |
| **Spacing** | Scale/Fluid |
| **Typography** | FontSize/FontWeight/LineHeight |
| **Radius** | xs/sm/md/lg/xl/full |
| **Shadow** | sm/md/lg/xl |

---

### Layer 8-9: Components (400行)

**Layer 8: Base Components (100行)** - 原子+布局组件
- Button, Input, Text, Image, Icon
- Box, Stack, HStack, VStack, Grid

**Layer 9: Business Components (300行)** - 分子+组织组件

**分子组件** (160行):
- Card, ListItem, Form, Modal, Tabs

**组织组件** (140行):
- UserProfile, ContentList, SearchBar, CommentSection

---

### Layer 11: Business Logic (100行)

**职责**: 业务规则实现、领域服务、事件处理

**服务分类**:
- **Domain Services**: UserService, ContentService, OrderService
- **Business Rules**: PriceCalculator, DiscountValidator
- **Event Handlers**: onUserLogin, onOrderComplete

---

### Layer 12: Application Shell (50行)

**职责**: 应用初始化、错误边界、性能监控

**组件**:
- ErrorBoundary（错误捕获）
- PerformanceMonitor（性能监控）
- GlobalProviders（Context提供者）

---

## 📋 文件命名规范体系

### 🏷️ 核心文件命名

| 文件类型 | 命名格式 | 职责描述 |
|---------|---------|----------|
| **主组件** | `index.[ext]` | 组件的主要UI实现和功能组装 |
| **类型定义** | `types.[ext]` | 数据结构、接口、类型定义 |
| **常量定义** | `constants.[ext]` | 组件相关的常量配置 |
| **组件文档** | `README.md` | 组件使用说明和API文档 |

### 🎣 状态管理命名

| 功能类型 | 命名格式 | 示例 |
|---------|---------|------|
| **主状态管理** | `use[ComponentName].[ext]` | `useUserCard.[ext]` |
| **功能状态** | `use[ComponentName][Feature].[ext]` | `useUserCardAnimation.[ext]` |
| **数据状态** | `use[ComponentName][DataSource].[ext]` | `useUserCardData.[ext]` |
| **表单状态** | `use[ComponentName][Form].[ext]` | `useUserCardForm.[ext]` |

### 🎯 事件处理命名

| 事件类型 | 命名格式 | 示例 |
|---------|---------|------|
| **基础交互** | `on[ComponentName][Action].[ext]` | `onUserCardClick.[ext]` |
| **复杂操作** | `on[ComponentName][UserAction].[ext]` | `onUserCardLongPress.[ext]` |
| **表单操作** | `on[ComponentName][FormAction].[ext]` | `onUserCardSubmit.[ext]` |

### 🧭 导航处理命名

| 导航类型 | 命名格式 | 示例 |
|---------|---------|------|
| **页面跳转** | `navigateTo[Target].[ext]` | `navigateToProfile.[ext]` |
| **返回导航** | `navigateBack[Source].[ext]` | `navigateBackFromProfile.[ext]` |
| **流程导航** | `navigate[ComponentName][Flow].[ext]` | `navigateUserCardFlow.[ext]` |

### 🌐 API接口命名

| 接口类型 | 命名格式 | 示例 |
|---------|---------|------|
| **基础接口** | `api[ComponentName][Action].[ext]` | `apiUserCardFetch.[ext]` |
| **数据源接口** | `api[ComponentName][DataSource].[ext]` | `apiUserCardProfile.[ext]` |
| **操作接口** | `api[ComponentName][Operation].[ext]` | `apiUserCardUpdate.[ext]` |

### 🔄 数据处理命名

| 处理类型 | 命名格式 | 示例 |
|---------|---------|------|
| **数据处理** | `process[ComponentName][Data].[ext]` | `processUserCardData.[ext]` |
| **数据转换** | `transform[ComponentName][Format].[ext]` | `transformUserCardFormat.[ext]` |
| **数据验证** | `validate[ComponentName][Input].[ext]` | `validateUserCardInput.[ext]` |

### 🛠️ 工具函数命名

| 工具类型 | 命名格式 | 示例 |
|---------|---------|------|
| **格式化** | `format[ComponentName][Display].[ext]` | `formatUserCardDisplay.[ext]` |
| **计算逻辑** | `calculate[ComponentName][Value].[ext]` | `calculateUserCardScore.[ext]` |
| **动画逻辑** | `animate[ComponentName][Transition].[ext]` | `animateUserCardTransition.[ext]` |

---

## 🎯 完整结构标准

### 🏗️ 扁平化完整结构（简单组件）

```
{ComponentName}/                               # 组件根目录
│
├─ 🏗️ 核心文件层（必需 - 100%实施）
│   ├─ index.[ext]                            # 主组件文件
│   ├─ types.[ext]                            # 类型定义
│   ├─ constants.[ext]                        # 常量定义
│   └─ README.md                              # 组件文档
│
├─ 🔄 状态管理层（按需实施）
│   ├─ use[ComponentName].[ext]               # 主状态管理
│   ├─ use[ComponentName][Feature].[ext]      # 功能状态
│   └─ use[ComponentName]Form.[ext]           # 表单状态
│
├─ ⚡ 事件处理层（按需实施）
│   ├─ on[ComponentName][Action].[ext]        # 基础交互
│   ├─ on[ComponentName]Submit.[ext]          # 表单操作
│   └─ on[ComponentName][FlowAction].[ext]    # 流程操作
│
├─ 🧭 导航处理层（按需实施）
│   ├─ navigateTo[Target].[ext]               # 页面跳转
│   └─ navigate[ComponentName]Flow.[ext]      # 流程导航
│
├─ 🌐 API接口层（按需实施）
│   ├─ api[ComponentName][Action].[ext]       # 基础接口
│   ├─ api[ComponentName]Update.[ext]         # 操作接口
│   └─ api[ComponentName]Batch.[ext]          # 批量接口
│
├─ 🔄 数据处理层（按需实施）
│   ├─ process[ComponentName][Data].[ext]     # 数据处理
│   ├─ transform[ComponentName]Format.[ext]   # 数据转换
│   └─ validate[ComponentName][Input].[ext]   # 数据验证
│
└─ 🛠️ 工具函数层（按需实施）
    ├─ format[ComponentName][Display].[ext]   # 格式化工具
    ├─ calculate[ComponentName][Value].[ext]  # 计算工具
    └─ animate[ComponentName]Transition.[ext] # 动画工具
```

### 🏗️ 嵌套化完整结构（复杂组件）

```
{ComplexComponent}/                            # 复杂组件根目录
│
├─ 🏗️ 父组件核心层（必需 - 100%实施）
│   ├─ index.[ext]                            # 主组件文件 - 组合子组件
│   ├─ types.[ext]                            # 类型定义 - 导出所有类型
│   ├─ constants.[ext]                        # 常量定义 - 导出所有常量
│   ├─ use[ComplexComponent].[ext]            # 主状态管理 - 协调子组件
│   └─ README.md                              # 组件文档 - 包含子组件说明
│
├─ 🔸 {FunctionalArea1}/（子组件1）
│   ├─ 🏗️ 子组件核心层（必需）
│   │   ├─ index.[ext]                        # 区域主文件
│   │   ├─ types.[ext]                        # 区域类型（可选）
│   │   └─ constants.[ext]                    # 区域常量（可选）
│   │
│   ├─ 🔄 子组件状态层（按需实施）
│   │   └─ use{FunctionalArea1}.[ext]         # 区域状态管理
│   │
│   ├─ ⚡ 子组件事件层（按需实施）
│   │   └─ on{FunctionalArea1}[Action].[ext]  # 区域事件处理
│   │
│   └─ 🌐 子组件API层（按需实施）
│       └─ api{FunctionalArea1}[Action].[ext] # 区域API接口
│
├─ 🔸 {FunctionalArea2}/（子组件2）
│   └─ [完整的子组件结构...]
│
└─ 🔸 {FunctionalArea3}/（子组件3）
    └─ [完整的子组件结构...]
```

### ✅ 完整结构验证清单

#### 核心文件验证（100%必需）
- [ ] `index.[ext]` - 主组件文件存在且功能完整
- [ ] `types.[ext]` - 类型定义文件存在且导出完整
- [ ] `constants.[ext]` - 常量定义文件存在且提取完整
- [ ] `README.md` - 组件文档存在且说明完整

#### 功能层级验证（按需必需）
- [ ] **状态管理层** - 有状态时必须创建 `use*.[ext]`
- [ ] **事件处理层** - 有交互时必须创建 `on*.[ext]`
- [ ] **导航处理层** - 有跳转时必须创建 `navigate*.[ext]`
- [ ] **API接口层** - 有数据交互时必须创建 `api*.[ext]`
- [ ] **数据处理层** - 有数据处理时必须创建 `process*.[ext]`
- [ ] **工具函数层** - 有工具函数时必须创建 `format*.[ext]`

#### 嵌套组件额外验证
- [ ] **子组件核心层** - 每个区域都有 `index.[ext]`
- [ ] **父子协调** - 父组件正确导入使用子组件
- [ ] **类型统一** - 父组件导出所有相关类型
- [ ] **常量集中** - 父组件导出所有相关常量

---

## 💡 代码实施原则（YAGNI + MVP）

### 🎯 核心原则

**架构完整 ≠ 代码复杂**：
- **架构层面**：结构必须完整，预留扩展空间（前瞻性设计）
- **代码层面**：最小可用实现，渐进完善（YAGNI + MVP）

### 📋 YAGNI原则（You Aren't Gonna Need It）
- **只实现当前需要的功能** - 不预先实现可能用到的功能
- **避免过度设计** - 不添加当前用不到的复杂逻辑
- **简单优先** - 优先选择最简单的实现方式

### 🚀 MVP原则（Minimum Viable Product）
- **最小可用实现** - 每个文件只包含核心必需功能
- **渐进式完善** - 后续根据实际需求逐步完善
- **快速迭代** - 优先实现可用版本，再优化完善

### 📋 实施示例

```typescript
// ✅ 推荐：YAGNI + MVP 实施

// types.ts - 只定义当前需要的类型
export interface UserCardProps {
  id: string;
  name: string;
  avatar?: string; // 可选属性
}

// constants.ts - 只定义当前使用的常量
export const USER_CARD_HEIGHT = 120;
export const DEFAULT_AVATAR = '/images/default-avatar.png';

// useUserCard.ts - 最小可用状态管理
export const useUserCard = (props: UserCardProps) => {
  const [isLoading, setIsLoading] = useState(false);
  return { isLoading, setIsLoading };
};

// ❌ 避免：过度设计
// 不要预先实现可能用不到的：
// - 复杂状态管理
// - 缓存机制
// - 复杂计算
// - 高级功能
```

### 🔄 渐进式完善策略

```
完整结构实施 = 架构完整 + 实现渐进

第一阶段：创建完整的文件结构框架
├─ 所有必需文件（index, types, constants, README）
├─ 所有按需文件（根据功能需求）
└─ 完整的目录层次结构

第二阶段：实施 YAGNI + MVP 代码填充
├─ 每个文件只实现当前需要的功能
├─ 避免过度设计和预先优化
└─ 保持代码简洁和可读性

第三阶段：根据实际需求渐进式完善
├─ 功能扩展时补充对应文件内容
├─ 重构时保持架构结构不变
└─ 持续优化和改进代码质量
```

---

## 🚀 性能优化策略

### 优化技术表

| 优化类别 | 技术方案 | 性能提升 |
|---------|---------|---------|
| **组件优化** | React.memo | 减少50%重渲染 |
| | useMemo | 避免重复计算 |
| | useCallback | 避免子组件重渲染 |
| **列表优化** | FlatList/虚拟列表 | 渲染1000+项无卡顿 |
| | windowSize | 减少内存占用 |
| | getItemLayout | 快速滚动 |
| **图片优化** | LazyLoad | 减少70%流量 |
| | Placeholder | 提升感知速度 |
| | FastImage | 更好的缓存 |
| **网络优化** | Request Cache | 命中率80%+ |
| | Request Debounce | 减少50%请求 |
| | Prefetch | 秒开页面 |
| **存储优化** | MMKV | 比AsyncStorage快10倍 |
| | Memory Cache | 毫秒级读取 |

### 优化规范

```yaml
组件优化:
  ✅ 所有组件使用React.memo
  ✅ 使用useMemo缓存计算
  ✅ 使用useCallback缓存函数
  ✅ 避免匿名函数（在JSX中）

列表优化:
  ✅ 使用FlatList（虚拟列表）
  ✅ windowSize配置（5-10）
  ✅ getItemLayout（固定高度）
  ✅ removeClippedSubviews

图片优化:
  ✅ 懒加载（LazyLoad）
  ✅ 占位图（Placeholder）
  ✅ 降级处理（Fallback）

网络优化:
  ✅ 请求缓存（Cache）
  ✅ 请求防抖（Debounce）
  ✅ 数据预加载（Prefetch）
```

---

## 🤖 Agent 执行指令

### 🎯 强制执行规则

#### 1. **架构选择**
- **自动决策**: 根据判断矩阵自动选择架构模式
- **项目级**: 使用 Features 模块化架构
- **页面级**: 根据复杂度选择扁平化/嵌套化
- **模块级**: 1000行+ 使用13层架构

#### 2. **完整结构强制要求**
- **100%强制实施完整结构** - 所有组件都必须按完整结构组织
- **核心文件层必需** - index, types, constants, README 必须100%创建
- **功能层按需必需** - 有相关功能时必须创建对应文件
- **不存在分级选择** - 不允许因"简化"而省略模块

#### 3. **必须创建的核心文件**

**扁平化架构**:
```
{ComponentName}/
├─ index.[ext]          ✅ 必需
├─ types.[ext]          ✅ 必需
├─ constants.[ext]      ✅ 必需
├─ README.md            ✅ 必需
└─ [功能文件...]        🟡 按需
```

**嵌套化架构**:
```
{ComplexComponent}/
├─ index.[ext]          ✅ 必需
├─ types.[ext]          ✅ 必需
├─ constants.[ext]      ✅ 必需
├─ README.md            ✅ 必需
├─ {FunctionalArea1}/   ✅ 必需（每个子组件）
│   ├─ index.[ext]      ✅ 必需
│   └─ [功能文件...]    🟡 按需
└─ {FunctionalArea2}/   ✅ 必需
```

#### 4. **禁止行为**
- ❌ 缺少核心文件
- ❌ 职责混合
- ❌ 类型定义缺失
- ❌ 常量硬编码
- ❌ 文件命名不规范
- ❌ 忽略错误处理

### 📋 重构执行步骤

#### 1️⃣ 分析阶段
```
✅ 确定架构层级（Project/Page/Module）
✅ 分析组件复杂度（扁平化 vs 嵌套化）
✅ 识别所有功能模块
✅ 列出完整文件清单
✅ 规划完整架构结构
```

#### 2️⃣ 创建阶段
```
1. 创建根目录
2. 创建核心文件（index, types, constants, README）
3. 根据复杂度创建功能文件
4. 嵌套组件创建子组件目录
```

#### 3️⃣ 重构阶段（遵循 YAGNI + MVP）
```
✅ 拆分代码到对应文件
✅ 提取类型定义（仅当前需要）
✅ 提取常量（仅当前使用）
✅ 拆分状态管理（最小可用）
✅ 拆分事件处理（核心事件）
✅ 重构主组件（简洁组装）
```

#### 4️⃣ 验证阶段
```
✅ 检查文件命名
✅ 检查职责单一
✅ 检查类型完整
✅ 检查导入导出
✅ 编写README文档
```

---

## ✅ 开发检查清单

### 提交前检查

```
架构层面:
✅ 正确使用架构层级（Features/Page/Module）
✅ 组件位置正确（无components/中间层）
✅ 架构模式选择正确（扁平化/嵌套化）
✅ 完整结构实施完整

代码层面:
✅ TypeScript编译无错误
✅ ESLint检查通过
✅ 所有组件已memo化
✅ 列表使用虚拟化
✅ 图片使用懒加载
✅ 网络请求有缓存

文档层面:
✅ README.md完整
✅ 注释完整规范
✅ 类型定义完整
✅ 常量全部提取

测试层面:
✅ 单元测试通过
✅ 功能测试通过
✅ 性能测试达标
```

### 发布前检查

```
✅ Bundle体积符合要求
✅ 首屏时间<1s
✅ FPS>55
✅ 内存占用<150MB
✅ 无内存泄漏
✅ 错误上报配置
✅ 性能监控配置
```

---

## 🚫 禁止清单

### 架构层面

```
❌ 在 features/{Module}/ 下创建 components/ 中间层
❌ 单文件组件（未按完整结构组织）
❌ 缺少核心文件（index/types/constants/README）
❌ 架构模式选择错误（该嵌套化却扁平化）
❌ 省略功能文件（有功能但无对应文件）
```

### 代码层面

```
❌ any类型（使用unknown或泛型）
❌ 类组件（使用函数组件+Hooks）
❌ 不必要的重渲染（未memo化）
❌ 全量列表渲染（使用虚拟列表）
❌ 硬编码配置（使用常量）
❌ console.log（使用日志服务）
❌ 魔法数字（使用命名常量）
❌ 超过50行的函数（拆分子函数）
```

---

## 🎯 核心原则（记住这20条）

### 项目级原则（5条）

```
1. Features模块化 - 按业务功能划分顶层模块
2. 模块完整性 - 每个模块包含完整业务闭环
3. 高内聚低耦合 - 模块内高度相关，模块间依赖最小
4. 可独立开发 - 模块可独立开发、测试、发布
5. 统一入口管理 - 模块通过API和事件通信
```

### 页面级原则（5条）

```
6. 扁平化组织 - 组件直接位于页面下，移除中间层
7. 架构模式决策 - 根据复杂度自动选择扁平化/嵌套化
8. 完整结构标准 - 所有组件按完整结构组织
9. 四大权力 - 位置、架构、功能、扩展权力
10. 层次映射 - 嵌套结构反映UI自然功能区域
```

### 模块级原则（5条）

```
11. 13层分离 - 大型模块按13层职责分离
12. 类型优先 - TypeScript严格模式，100%类型覆盖
13. 组合优于继承 - 使用函数式编程
14. 性能第一 - 所有组件memo化，列表虚拟化
15. 可测试性 - 纯函数+依赖注入
```

### 通用原则（5条）

```
16. 具名化 - 所有文件使用明确含义的名称
17. 单一职责 - 每个文件只负责一个功能
18. YAGNI原则 - 只实现当前需要的功能
19. MVP原则 - 最小可用实现，渐进完善
20. 架构完整+代码简洁 - 结构完整但实现简洁
```

---

## 📊 关键指标

### 质量指标

| 指标 | 目标 | 说明 |
|------|------|------|
| **架构一致性** | 100% | 所有模块遵循统一架构 |
| **类型覆盖率** | >95% | TypeScript类型覆盖 |
| **组件memo率** | 100% | 所有组件memo化 |
| **测试覆盖率** | >80% | 单元测试覆盖 |
| **Bundle体积** | <2MB | 生产环境打包体积 |
| **首屏时间** | <1s | 白屏到可交互时间 |
| **FPS** | >55 | 滚动帧率 |

### 开发效率指标

| 指标 | 目标 | 说明 |
|------|------|------|
| **开发时间** | 可控 | 架构清晰，开发高效 |
| **维护成本** | 低 | 结构清晰易维护 |
| **扩展性** | 高 | 可平滑扩展 |
| **复用率** | >70% | 组件可复用比例 |

---

## 📚 适用场景总结

### 何时使用Features架构
- ✅ 大型应用（多个业务模块）
- ✅ 需要模块化管理
- ✅ 多人团队协作
- ✅ 独立开发和部署

### 何时使用伪页面组件架构
- ✅ 页面级组件组织
- ✅ 功能组件复用
- ✅ 清晰的组件层级
- ✅ 独立测试和维护

### 何时使用13层架构
- ✅ 1000行+ 大型模块
- ✅ 复杂业务逻辑
- ✅ 单文件实现
- ✅ 需要清晰职责分离

---

## 📄 文档信息

**版本**: v3.0  
**更新日期**: 2025-11-07  
**适用范围**: React / React Native / Vue / 通用前端项目  
**架构标准**: 三层架构体系（Project → Page → Module）  
**维护者**: 前端架构团队

---

**架构清晰，层级分明，职责明确，质量第一。**

**三层架构递进，从项目到模块，全面覆盖！** 🚀✨

