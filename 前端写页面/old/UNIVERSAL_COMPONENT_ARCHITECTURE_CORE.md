# 通用组件模块化架构核心标准

## 🤖 Agent 执行指令 (重要)

**当 Agent 接收到本架构文档时，必须严格按照以下要求执行：**

### 🎯 强制执行规则

1. **📁 混合架构重构 (扁平化 + 嵌套化)**
   - 必须按照"混合架构模式"进行重构
   - 组件位置：`src/screens/{PageName}/{ComponentName}/`
   - 移除 `components/` 中间层级，让组件直接位于页面下
   - **架构模式选择**：根据组件复杂度选择扁平化或嵌套化模式
   - **简单组件**：使用扁平化架构 (UI层次≤2层，功能模块≤3个)
   - **复杂组件**：使用嵌套化架构 (UI层次≥3层，功能模块≥4个)
   - 不得省略任何应该包含的文件类型
   - 必须使用文档中定义的命名规范

2. **🔧 完整结构强制要求 (架构核心)**
   - **100%强制实施完整结构** - 所有组件都必须严格按照完整结构标准组织
   - **核心文件层必需** - index.[ext]、types.[ext]、constants.[ext]、README.md 必须100%创建
   - **功能层按需必需** - 有相关功能时必须创建对应的功能层文件，不允许职责混合
   - **配套层同时出现** - API接口层与后端交互层必须配套创建，不允许单独存在
   - **嵌套结构完整** - 复杂组件的每个子组件都必须遵循完整的子组件结构标准
   - **不存在分级选择** - 不允许因为"简化"而省略应有的模块拆分和文件创建

3. **📋 必须创建的核心文件 (混合架构)**

   **🟢 扁平化架构 (简单组件)**
   ```
   src/screens/{PageName}/{SimpleComponent}/   # 简单伪页面组件根目录
   ├── index.[ext]                             # 主组件文件 (必需)
   ├── types.[ext]                             # 类型定义 (必需)
   ├── constants.[ext]                         # 常量定义 (必需)
   ├── use{ComponentName}.[ext]                # 主状态管理 (必需)
   ├── [其他功能文件按需创建...]
   └── README.md                               # 组件文档 (必需)
   ```

   **🔵 嵌套化架构 (复杂组件)**
   ```
   src/screens/{PageName}/{ComplexComponent}/  # 复杂伪页面组件根目录
   ├── index.[ext]                             # 主组件文件 - 组合子组件 (必需)
   ├── types.[ext]                             # 类型定义 - 导出所有类型 (必需)
   ├── constants.[ext]                         # 常量定义 - 导出所有常量 (必需)
   ├── use{ComponentName}.[ext]                # 主状态管理 - 协调子组件 (必需)
   ├── README.md                               # 组件文档 - 包含子组件说明 (必需)
   │
   ├── {FunctionalArea1}/                      # 功能区域1 (子组件)
   │   ├── index.[ext]                         # 区域主文件 (必需)
   │   ├── types.[ext]                         # 区域类型定义 (可选)
   │   ├── constants.[ext]                     # 区域常量 (可选)
   │   └── [区域功能文件...]                   # 按需创建
   │
   └── {FunctionalArea2}/                      # 功能区域2 (子组件)
       ├── index.[ext]                         # 区域主文件 (必需)
       └── [区域功能文件...]                   # 按需创建
   ```
   
   **重要：当需要API接口时，必须同时创建前端接口层和后端交互层！**

4. **🚫 完整结构禁止行为 (严格执行)**
   - **禁止省略核心文件** - 不允许缺少 index.[ext]、types.[ext]、constants.[ext]、README.md
   - **禁止职责混合** - 不允许将多个功能层的职责混合在一个文件中
   - **禁止文件命名不规范** - 必须严格按照命名规范，不允许使用模糊的文件名
   - **禁止类型定义缺失** - 不允许省略必要的接口和类型定义
   - **禁止常量硬编码** - 不允许在代码中硬编码常量，必须提取到 constants.[ext]
   - **禁止API接口不配套** - 不允许只创建前端API接口而不创建对应的后端交互层
   - **禁止功能文件缺失** - 有相关功能时不允许缺少对应的功能层文件
   - **禁止嵌套结构不完整** - 复杂组件的子组件不允许缺少核心文件
   - **禁止忽略错误处理和边界情况**

5. **✅ 完整结构验证清单 (强制检查)**
   - **架构模式验证** - 检查是否正确选择了架构模式 (扁平化 vs 嵌套化)
   - **核心文件验证** - 检查是否100%创建了所有核心文件 (index, types, constants, README)
   - **功能层验证** - 检查是否按需创建了所有相关功能层文件
   - **命名规范验证** - 检查所有文件命名是否严格符合规范
   - **职责分离验证** - 检查每个文件职责是否单一明确，无混合职责
   - **类型定义验证** - 检查是否包含完整的类型定义，无缺失
   - **常量提取验证** - 检查是否提取了所有常量，无硬编码
   - **文档完整验证** - 检查是否提供了完整的使用文档
   - **API配套验证** - 检查API接口层是否配套了完整的后端交互层
   - **嵌套结构验证** (复杂组件额外检查)：
     - 子组件核心文件完整性 - 每个子组件都有完整的核心文件
     - 功能区域边界合理性 - 子组件边界与UI功能区域对应
     - 父子协调正确性 - 父组件正确协调子组件状态
     - 子组件内聚性 - 子组件高度内聚，职责清晰
     - 类型和常量统一性 - 父组件统一导出所有相关类型和常量

### 🎭 混合架构实施要求

- **扁平化组织**: 所有组件必须直接位于 `src/screens/{PageName}/{ComponentName}/`
- **移除中间层**: 禁止使用 `components/` 中间层级
- **架构模式决策**: 根据组件复杂度判断矩阵选择合适的架构模式
- **统一标准**: 所有伪页面组件都必须按照"完整结构"进行重构
- **不允许简化**: 不得因为组件看似简单而省略应有的模块拆分
- **前瞻性设计**: 即使当前功能简单，也要为未来扩展预留完整的架构空间
- **平等地位**: 伪页面组件与页面主文件处于同一目录层级
- **嵌套层级控制**: 嵌套组件最多3级层次 (页面 → 组件 → 子组件 → 孙组件)
- **功能区域映射**: 嵌套结构必须反映UI的自然功能区域划分

### 💡 代码实施原则 (YAGNI + MVP)

**架构完整 ≠ 代码复杂**：虽然架构必须完整，但具体实施的文件代码必须遵循 **YAGNI + MVP** 原则：

#### 🎯 **YAGNI 原则** (You Aren't Gonna Need It)
- **只实现当前需要的功能** - 不预先实现可能用到的功能
- **避免过度设计** - 不添加当前用不到的复杂逻辑
- **简单优先** - 优先选择最简单的实现方式

#### 🚀 **MVP 原则** (Minimum Viable Product)
- **最小可用实现** - 每个文件只包含核心必需功能
- **渐进式完善** - 后续根据实际需求逐步完善
- **快速迭代** - 优先实现可用版本，再优化完善

#### 📋 **实施策略**

```typescript
// ✅ 推荐：YAGNI + MVP 实施
// types.ts - 只定义当前需要的类型
export interface UserCardProps {
  id: string;
  name: string;
  avatar?: string;
}

// constants.ts - 只定义当前使用的常量
export const USER_CARD_HEIGHT = 120;

// useUserCard.ts - 只实现核心状态管理
export const useUserCard = (props: UserCardProps) => {
  const [isLoading, setIsLoading] = useState(false);
  return { isLoading, setIsLoading };
};

// ❌ 避免：过度设计
// 不要预先实现可能用不到的复杂状态管理、缓存机制、复杂计算等
```

#### 🔄 **架构与实施的平衡**

| 层面 | 要求 | 原则 |
|------|------|------|
| **架构层面** | 完整结构，预留扩展空间 | 前瞻性设计 |
| **代码层面** | 最小可用实现，渐进完善 | YAGNI + MVP |

### 📝 YAGNI + MVP 代码编写指导

#### 🎯 **各文件类型的 YAGNI + MVP 实施标准**

##### **types.ts - 类型定义文件**
```typescript
// ✅ 推荐：只定义当前需要的类型
export interface UserCardProps {
  id: string;
  name: string;
  avatar?: string; // 可选属性用 ? 标记
}

// ❌ 避免：预定义可能用到的复杂类型
// export interface UserCardAdvancedProps extends UserCardProps {
//   permissions?: Permission[];
//   metadata?: Record<string, any>;
//   callbacks?: UserCardCallbacks;
// }
```

##### **constants.ts - 常量定义文件**
```typescript
// ✅ 推荐：只定义当前使用的常量
export const USER_CARD_HEIGHT = 120;
export const DEFAULT_AVATAR = '/images/default-avatar.png';

// ❌ 避免：预定义大量可能用到的常量
// export const USER_CARD_ANIMATION_DURATION = 300;
// export const USER_CARD_CACHE_TTL = 5 * 60 * 1000;
// export const USER_CARD_RETRY_ATTEMPTS = 3;
```

##### **use[ComponentName].ts - 状态管理文件**
```typescript
// ✅ 推荐：最小可用状态管理
export const useUserCard = (props: UserCardProps) => {
  const [isLoading, setIsLoading] = useState(false);
  
  return {
    isLoading,
    setIsLoading,
  };
};

// ❌ 避免：复杂的状态管理预设
// const [cache, setCache] = useState<Map<string, UserData>>(new Map());
// const [retryCount, setRetryCount] = useState(0);
// const [lastFetchTime, setLastFetchTime] = useState<Date | null>(null);
```

##### **on[ComponentName][Action].ts - 事件处理文件**
```typescript
// ✅ 推荐：核心事件处理
export const onUserCardClick = (userId: string) => {
  console.log('User card clicked:', userId);
  // 基础点击处理逻辑
};

// ❌ 避免：复杂的事件处理预设
// export const onUserCardDoubleClick = ...
// export const onUserCardLongPress = ...
// export const onUserCardSwipe = ...
```

##### **api[ComponentName][Action].ts - API接口文件**
```typescript
// ✅ 推荐：核心API接口
export const apiUserCardFetch = async (id: string) => {
  const response = await fetch(`/api/users/${id}`);
  return response.json();
};

// ❌ 避免：预设复杂API接口
// export const apiUserCardBatchFetch = ...
// export const apiUserCardCacheManager = ...
// export const apiUserCardRetryWrapper = ...
```

#### 🔄 **渐进式完善策略**

1. **第一版实现** - MVP 版本
   - 只实现核心必需功能
   - 基础的类型定义和状态管理
   - 简单的事件处理和API调用

2. **后续迭代** - 根据实际需求扩展
   - 添加新的类型定义（当需要时）
   - 扩展状态管理（当业务复杂时）
   - 增加事件处理（当交互丰富时）
   - 完善API接口（当数据需求增加时）

#### 💡 **YAGNI + MVP 核心原则**

| 原则 | 说明 | 实施方式 |
|------|------|----------|
| **需要时再添加** | 不预先实现可能用到的功能 | 从最简单的实现开始 |
| **保持简洁** | 每个文件只包含核心功能 | 避免过度抽象和复杂逻辑 |
| **快速迭代** | 优先可用版本，后续完善 | MVP → 渐进式改进 |
| **避免过度设计** | 不添加当前用不到的代码 | 专注于当前需求 |

**🎯 完整结构核心提醒：**
- **完整结构是绝对核心** - 所有组件都必须100%按照完整结构标准组织，这是非协商的强制要求
- **自动架构模式选择** - 根据组件复杂度自动选择扁平化或嵌套化模式，不要问用户"是否需要"
- **架构完整 + 代码简洁** - 文件结构必须完整，但具体代码实现必须遵循 YAGNI + MVP 原则
- **强制验证检查** - 必须通过完整结构验证清单的所有检查项，违规即为架构失败

### 🎯 架构模式选择实例

#### 决策过程示例：

**UserCard 组件分析**:
- ✅ UI层次 = 4层 (卡片 → 区域 → 元素 → 状态) ≥ 3层
- ✅ 功能模块 = 6个 (头像、资料、统计、操作、交互、状态) ≥ 4个  
- ✅ 有明确功能区域划分 (5个独立区域)
- ✅ 子组件高度内聚 (每个区域专注特定功能)
- ✅ 跨页面复用价值中等 (主要在用户相关页面)

**结论**: 🔵 选择嵌套化架构

**SearchBar 组件分析**:
- ✅ UI层次 = 2层 (输入框 → 下拉建议) ≤ 2层
- ✅ 功能模块 = 3个 (输入、搜索、建议) ≤ 3个
- ✅ 跨页面复用价值高 (可在多个页面使用)
- ✅ 功能相对独立简单

**结论**: 🟢 选择扁平化架构

---

## 📖 核心理念

本文档定义了一套**跨框架、跨语言的通用组件模块化架构标准**，基于**具名化、模块化、职责分离**的核心思想，适用于任何现代前端框架和编程语言。

## 🎯 四大设计原则

### 1. 框架无关性 (Framework Agnostic)
- 架构思想不依赖特定的技术栈
- 命名规范和文件组织方式通用
- 可在任何支持模块化的语言中实现

### 2. 具名化原则 (Explicit Naming)
- 所有文件都使用具有明确含义的名称
- 文件名直接反映其功能和职责
- 避免使用模糊的通用名称

### 3. 单一职责原则 (Single Responsibility)
- 每个文件只负责一个具体的功能
- 状态管理、事件处理、导航逻辑各司其职
- 便于单独测试、维护和复用

### 4. 自包含原则 (Self-Contained)
- 每个组件模块包含其所有相关代码
- 类型定义、常量、逻辑都在模块内部
- 减少跨模块依赖，提高内聚性

## 🏗️ 伪页面组件架构 (Pseudo-Page Component Architecture)

### 📍 伪页面组件定义

**伪页面组件**是一种灵活的组件组织方式，支持**扁平化**和**嵌套化**两种模式，让组件直接位于页面层级下，拥有更大的架构自主权，成为具有页面级别功能复杂度的独立组件模块。

### 🎭 混合架构模式 (Hybrid Architecture)

基于组件复杂度和UI层次，支持两种组织模式：

#### 🟢 **扁平化模式** - 适用于简单组件
- 组件功能相对独立和简单
- UI结构层次较浅
- 跨页面复用价值较高

#### 🔵 **嵌套化模式** - 适用于复杂组件  
- 组件内部有明确的功能区域划分
- UI层次结构复杂，需要体现自然层次
- 子组件高度内聚，主要为父组件服务

### 🎯 混合架构树状图对比

#### 🟢 **扁平化架构** (适用于简单组件)

```
src/screens/                                        # 页面容器层
├── {PageName}/                                     # 具名页面 (如 discover, home, profile)
│   ├── {SimpleComponent}/                          # ✅ 简单伪页面组件 (扁平化)
│   │   ├── index.[ext]                             # 主组件文件
│   │   ├── types.[ext]                             # 类型定义
│   │   ├── constants.[ext]                         # 常量配置
│   │   ├── use{ComponentName}.[ext]                # 状态管理
│   │   ├── on{ComponentName}[Action].[ext]         # 事件处理
│   │   └── [其他架构文件...]                       # 按完整架构标准组织
│   │
│   ├── {AnotherSimpleComponent}/                   # ✅ 另一个简单伪页面组件
│   ├── {PageName}Screen.[ext]                      # 页面主文件
│   ├── hooks/                                      # 页面级状态管理
│   ├── events/                                     # 页面级事件处理
│   └── services/                                   # 页面级数据服务
```

#### 🔵 **嵌套化架构** (适用于复杂组件)

```
src/screens/                                        # 页面容器层
├── {PageName}/                                     # 具名页面 (如 discover, home, profile)
│   ├── {ComplexComponent}/                         # ✅ 复杂伪页面组件 (嵌套化)
│   │   ├── index.[ext]                             # 主组件文件 - 组合子组件
│   │   ├── types.[ext]                             # 类型定义 - 导出所有相关类型
│   │   ├── constants.[ext]                         # 常量配置 - 导出所有相关常量
│   │   ├── use{ComplexComponent}.[ext]             # 主状态管理 - 协调子组件状态
│   │   ├── README.md                               # 组件文档 - 包含子组件说明
│   │   │
│   │   ├── {FunctionalArea1}/                      # 🔸 功能区域1 (子组件)
│   │   │   ├── index.[ext]                         # 区域主文件
│   │   │   ├── types.[ext]                         # 区域类型定义
│   │   │   ├── constants.[ext]                     # 区域常量
│   │   │   ├── use{FunctionalArea1}.[ext]          # 区域状态管理
│   │   │   ├── on{FunctionalArea1}[Action].[ext]   # 区域事件处理
│   │   │   └── api{FunctionalArea1}[Action].[ext]  # 区域API接口
│   │   │
│   │   ├── {FunctionalArea2}/                      # 🔸 功能区域2 (子组件)
│   │   │   ├── index.[ext]                         # 区域主文件
│   │   │   ├── constants.[ext]                     # 区域常量
│   │   │   ├── process{FunctionalArea2}Data.[ext]  # 区域数据处理
│   │   │   └── format{FunctionalArea2}Display.[ext] # 区域格式化工具
│   │   │
│   │   └── {FunctionalArea3}/                      # 🔸 功能区域3 (子组件)
│   │       ├── index.[ext]                         # 区域主文件
│   │       ├── use{FunctionalArea3}.[ext]          # 区域状态管理
│   │       └── navigate{FunctionalArea3}Flow.[ext] # 区域导航处理
│   │
│   ├── {AnotherComplexComponent}/                  # ✅ 另一个复杂伪页面组件
│   ├── {PageName}Screen.[ext]                      # 页面主文件
│   ├── hooks/                                      # 页面级状态管理
│   ├── events/                                     # 页面级事件处理
│   └── services/                                   # 页面级数据服务
```

### 🚫 移除的中间层级

**不再使用的组织方式 (已废弃)**:
```
src/screens/{PageName}/
├── components/                                     # ❌ 移除的中间层
│   ├── {ComponentName}/                            # ❌ 过深的嵌套
│   └── {AnotherComponent}/                         # ❌ 过深的嵌套
```

### 🎭 伪页面组件的四大权力

#### 1. **位置权力** - 平等地位
- **直接位于页面下**: `src/screens/{PageName}/{ComponentName}/`
- **无中间层级**: 移除 `components/` 层级
- **与页面主文件平等**: 处于同一目录层级
- **支持嵌套扩展**: 复杂组件可以包含子组件区域

#### 2. **架构权力** - 完整自主
- **完整应用架构标准**: 按 UNIVERSAL_COMPONENT_ARCHITECTURE_CORE 组织
- **自主文件组织**: 内部可以有完整的文件结构
- **独立职责分离**: 状态、事件、数据处理等各司其职
- **嵌套架构决策权**: 根据复杂度选择扁平化或嵌套化模式

#### 3. **功能权力** - 业务完整
- **状态管理权**: 可以有自己的 `use{ComponentName}.ts`
- **事件处理权**: 可以有自己的 `on{ComponentName}[Action].ts`
- **数据处理权**: 可以有自己的 `process{ComponentName}[Data].ts`
- **API调用权**: 可以有自己的 `api{ComponentName}[Action].ts`
- **子组件协调权**: 复杂组件可以协调管理多个功能区域

#### 4. **扩展权力** - 成长潜力
- **可成长为子页面**: 功能复杂时可以进一步扩展
- **独立测试维护**: 可以独立进行单元测试和维护
- **团队协作友好**: 可以由不同开发者独立开发
- **模块化拆分**: 复杂组件可以拆分为多个功能区域模块

## 🎯 混合架构设计原则与标准

### 📊 组件复杂度判断矩阵

#### 🟢 **扁平化模式适用标准**

| 维度 | 标准 | 说明 |
|------|------|------|
| **UI层次** | ≤ 2层 | 组件内部UI结构相对简单 |
| **功能模块** | ≤ 3个 | 包含的主要功能模块数量较少 |
| **状态复杂度** | 简单 | 状态管理逻辑相对简单 |
| **复用价值** | 高 | 跨页面、跨项目复用价值较高 |
| **独立性** | 强 | 功能相对独立，依赖较少 |

**示例组件**: `Button`、`Input`、`Card`、`Modal`、`UserAvatar`、`SearchBar`

#### 🔵 **嵌套化模式适用标准**

| 维度 | 标准 | 说明 |
|------|------|------|
| **UI层次** | ≥ 3层 | 组件内部有明确的区域划分 |
| **功能模块** | ≥ 4个 | 包含多个独立的功能区域 |
| **状态复杂度** | 复杂 | 需要协调多个子组件的状态 |
| **复用价值** | 中等 | 主要在特定业务场景中复用 |
| **内聚性** | 强 | 子组件高度内聚，为父组件服务 |

**示例组件**: `UserCard`、`ProductPanel`、`CommentSection`、`MediaPlayer`、`DataTable`

### 🏗️ 嵌套组件设计原则

#### 🎯 **命名规范**
- **父组件**: 使用业务实体名称 - `UserCard`、`ProductPanel`、`OrderForm`
- **子组件**: 使用功能区域名称 - `HeaderArea`、`ContentArea`、`ActionArea`、`InfoSection`
- **层级限制**: 建议最多 **3级嵌套** (页面 → 组件 → 子组件 → 孙组件)

#### 🔗 **依赖关系原则**
- **向上依赖**: 子组件可以接收父组件传递的 props 和 context
- **向下隔离**: 父组件不应直接访问子组件内部状态
- **平级独立**: 同级子组件应该相对独立，避免直接依赖
- **状态提升**: 共享状态应该提升到最近的公共父组件

#### 📦 **导出策略**
- **主要导出**: 父组件作为主要导出，子组件一般不对外导出
- **类型统一**: 父组件的 `types.[ext]` 导出所有相关类型定义
- **常量集中**: 父组件的 `constants.[ext]` 导出所有相关常量
- **文档完整**: 父组件的 `README.md` 包含所有子组件的使用说明

#### 🎨 **UI层次映射**
- **自然映射**: 代码结构应该反映UI的自然层次结构
- **功能分组**: 相关功能的UI元素应该组织在同一个子组件中
- **视觉边界**: 子组件边界应该与视觉设计的区域边界对应
- **交互独立**: 每个子组件应该处理自己区域内的交互逻辑

### 🚀 架构模式选择决策树

```
组件架构模式选择
│
├── UI层次 ≤ 2层？
│   ├── 是 → 功能模块 ≤ 3个？
│   │   ├── 是 → 🟢 选择扁平化模式
│   │   └── 否 → 继续评估...
│   └── 否 → 继续评估...
│
├── 有明确功能区域划分？
│   ├── 是 → 子组件高度内聚？
│   │   ├── 是 → 🔵 选择嵌套化模式
│   │   └── 否 → 🟢 选择扁平化模式
│   └── 否 → 🟢 选择扁平化模式
│
└── 跨页面复用价值高？
    ├── 是 → 🟢 选择扁平化模式
    └── 否 → 🔵 选择嵌套化模式
```

## 📁 通用目录结构标准 - 混合架构完整结构

### 🎯 完整结构核心理念 (统一标准，必须实施)

**完整结构**是本架构标准的**绝对核心**，所有组件无论简单或复杂，都必须严格按照完整结构进行组织。这是**非协商的强制标准**，确保：
- ✅ **架构一致性** - 所有组件遵循统一的组织模式
- ✅ **可扩展性** - 为未来功能扩展预留完整空间
- ✅ **可维护性** - 清晰的职责分离和模块边界
- ✅ **团队协作** - 标准化的开发和维护流程

### 🏗️ 混合架构完整结构标准

#### 🟢 **扁平化完整结构** (简单组件适用)

```
src/screens/{PageName}/{ComponentName}/             # 伪页面组件根目录
│
├── 🏗️ 核心文件层 (必需 - 100%实施)
│   ├── index.[ext]                                 # 主组件文件 - UI渲染和功能组装
│   ├── types.[ext]                                 # 类型定义 - 接口、类型、约束
│   ├── constants.[ext]                             # 常量定义 - 配置、默认值
│   └── README.md                                   # 组件文档 - 使用说明、API
│
├── 🔄 状态管理层 (按需实施 - 根据功能需求)
│   ├── use[ComponentName].[ext]                    # 主状态管理 - 核心业务状态
│   ├── use[ComponentName][Feature].[ext]           # 功能状态 - 特定功能状态
│   ├── use[ComponentName]Form.[ext]                # 表单状态 - 表单数据管理
│   └── use[ComponentName]Data.[ext]                # 数据状态 - 数据获取管理
│
├── ⚡ 事件处理层 (按需实施 - 根据交互需求)
│   ├── on[ComponentName][Action].[ext]             # 基础交互 - 点击、输入事件
│   ├── on[ComponentName][UserAction].[ext]         # 复杂操作 - 长按、滑动事件
│   ├── on[ComponentName]Submit.[ext]               # 表单操作 - 提交、验证事件
│   └── on[ComponentName][FlowAction].[ext]         # 流程操作 - 多步骤事件
│
├── 🧭 导航处理层 (按需实施 - 根据导航需求)
│   ├── navigateTo[Target].[ext]                    # 页面跳转 - 目标页面导航
│   ├── navigateBack[Source].[ext]                  # 返回导航 - 返回上级页面
│   └── navigate[ComponentName]Flow.[ext]           # 流程导航 - 多步骤流程
│
├── 🌐 API接口层 (配套实施 - 与后端交互层同时出现)
│   ├── api[ComponentName][Action].[ext]            # 基础接口 - 数据获取接口
│   ├── api[ComponentName][DataSource].[ext]        # 数据源接口 - 特定数据源
│   ├── api[ComponentName]Update.[ext]              # 操作接口 - 数据更新接口
│   └── api[ComponentName]Batch.[ext]               # 批量接口 - 批量操作接口
│
├── 🔌 后端交互层 (配套实施 - 与API接口层同时出现)
│   └── backend/                                    # 后端代码文件夹
│       ├── entity[ComponentName].[ext]             # 实体类 - 数据模型定义
│       ├── dto[ComponentName][Action].[ext]        # 数据传输对象 - 请求响应模型
│       ├── controller[ComponentName].[ext]         # 控制器 - REST API接口
│       ├── service[ComponentName].[ext]            # 业务服务 - QueryWrapper业务逻辑
│       ├── mapper[ComponentName].[ext]             # 数据访问接口 - 仅在需要特殊查询时
│       └── sql[ComponentName].xml                  # 复杂SQL查询 - 仅在极复杂SQL时
│
├── 🔄 数据处理层 (按需实施 - 根据数据处理需求)
│   ├── process[ComponentName][Data].[ext]          # 数据处理 - 原始数据处理
│   ├── transform[ComponentName]Format.[ext]        # 数据转换 - 格式转换逻辑
│   ├── validate[ComponentName][Input].[ext]        # 数据验证 - 输入验证逻辑
│   └── filter[ComponentName]List.[ext]             # 数据过滤 - 筛选过滤逻辑
│
└── 🛠️ 工具函数层 (按需实施 - 根据工具需求)
    ├── format[ComponentName][Display].[ext]        # 格式化工具 - 显示格式化
    ├── calculate[ComponentName][Value].[ext]       # 计算工具 - 数值计算逻辑
    ├── animate[ComponentName]Transition.[ext]      # 动画工具 - 动画过渡效果
    └── sort[ComponentName]List.[ext]               # 排序工具 - 列表排序逻辑
```

#### 🔵 **嵌套化完整结构** (复杂组件适用)

```
src/screens/{PageName}/{ComplexComponent}/          # 复杂伪页面组件根目录
│
├── 🏗️ 父组件核心层 (必需 - 100%实施)
│   ├── index.[ext]                                 # 主组件文件 - 组合子组件，协调整体
│   ├── types.[ext]                                 # 类型定义 - 导出所有相关类型
│   ├── constants.[ext]                             # 常量定义 - 导出所有相关常量
│   ├── use[ComplexComponent].[ext]                 # 主状态管理 - 协调子组件状态
│   └── README.md                                   # 组件文档 - 包含所有子组件说明
│
├── 🔸 {FunctionalArea1}/ (子组件1 - 功能区域)
│   ├── 🏗️ 子组件核心层 (必需)
│   │   ├── index.[ext]                             # 区域主文件 - UI渲染和功能实现
│   │   ├── types.[ext]                             # 区域类型定义 (可选)
│   │   └── constants.[ext]                         # 区域常量 (可选)
│   │
│   ├── 🔄 子组件状态层 (按需实施)
│   │   ├── use{FunctionalArea1}.[ext]              # 区域状态管理
│   │   └── use{FunctionalArea1}[Feature].[ext]     # 区域功能状态
│   │
│   ├── ⚡ 子组件事件层 (按需实施)
│   │   ├── on{FunctionalArea1}[Action].[ext]       # 区域事件处理
│   │   └── on{FunctionalArea1}[UserAction].[ext]   # 区域用户操作
│   │
│   ├── 🌐 子组件API层 (按需实施)
│   │   └── api{FunctionalArea1}[Action].[ext]      # 区域API接口
│   │
│   ├── 🔄 子组件数据层 (按需实施)
│   │   └── process{FunctionalArea1}[Data].[ext]    # 区域数据处理
│   │
│   └── 🛠️ 子组件工具层 (按需实施)
│       └── format{FunctionalArea1}[Display].[ext]  # 区域格式化工具
│
├── 🔸 {FunctionalArea2}/ (子组件2 - 功能区域)
│   ├── 🏗️ 子组件核心层 (必需)
│   │   ├── index.[ext]                             # 区域主文件
│   │   ├── types.[ext]                             # 区域类型定义 (可选)
│   │   └── constants.[ext]                         # 区域常量 (可选)
│   │
│   └── [其他功能层按需实施...]                      # 根据区域复杂度添加
│
├── 🔸 {FunctionalArea3}/ (子组件3 - 功能区域)
│   └── [完整的子组件结构...]                        # 每个区域都遵循完整结构
│
├── 🔄 父组件状态层 (按需实施 - 协调性状态管理)
│   ├── use[ComplexComponent][Coordination].[ext]   # 协调状态管理
│   └── use[ComplexComponent]Data.[ext]             # 整体数据管理
│
├── ⚡ 父组件事件层 (按需实施 - 跨区域事件处理)
│   └── on[ComplexComponent][GlobalAction].[ext]    # 全局事件处理
│
├── 🌐 父组件API层 (配套实施 - 整体API管理)
│   └── api[ComplexComponent][Aggregate].[ext]      # 聚合API接口
│
├── 🔌 后端交互层 (配套实施 - 与API接口层同时出现)
│   └── backend/                                    # 后端代码文件夹
│       ├── entity[ComplexComponent].[ext]          # 实体类 - 数据模型定义
│       ├── dto[ComplexComponent][Action].[ext]     # 数据传输对象 - 请求响应模型
│       ├── controller[ComplexComponent].[ext]      # 控制器 - REST API接口
│       ├── service[ComplexComponent].[ext]         # 业务服务 - QueryWrapper业务逻辑
│       ├── mapper[ComplexComponent].[ext]          # 数据访问接口 - 仅在需要特殊查询时
│       └── sql[ComplexComponent].xml               # 复杂SQL查询 - 仅在极复杂SQL时
│
└── 🛠️ 父组件工具层 (按需实施 - 跨区域工具函数)
    └── format[ComplexComponent][GlobalDisplay].[ext] # 全局格式化工具
```

### 🚀 完整结构强制实施标准

#### 🎯 **实施层级定义**

| 实施级别 | 说明 | 执行要求 | 违规后果 |
|---------|------|----------|----------|
| **必需 - 100%实施** | 所有组件都必须包含 | 无条件创建，不允许省略 | 架构验证失败 |
| **配套实施** | API层与后端层必须同时出现 | 创建API接口时必须配套后端层 | 功能不完整 |
| **按需实施** | 根据实际功能需求创建 | 有相关功能时必须创建对应文件 | 职责混乱 |

#### 🔧 **完整结构实施检查清单**

##### ✅ **核心文件层检查 (100%必需)**
- [ ] `index.[ext]` - 主组件文件存在且功能完整
- [ ] `types.[ext]` - 类型定义文件存在且导出完整
- [ ] `constants.[ext]` - 常量定义文件存在且提取完整
- [ ] `README.md` - 组件文档存在且说明完整

##### 🔄 **功能层级检查 (按需必需)**
- [ ] **状态管理层** - 有状态管理需求时必须创建对应的 `use*.[ext]` 文件
- [ ] **事件处理层** - 有用户交互时必须创建对应的 `on*.[ext]` 文件
- [ ] **导航处理层** - 有页面跳转时必须创建对应的 `navigate*.[ext]` 文件
- [ ] **API接口层** - 有数据交互时必须创建对应的 `api*.[ext]` 文件
- [ ] **后端交互层** - 有API接口时必须配套创建 `backend/` 文件夹
- [ ] **数据处理层** - 有数据处理时必须创建对应的 `process*.[ext]` 文件
- [ ] **工具函数层** - 有工具函数时必须创建对应的 `format*.[ext]` 文件

##### 🔸 **嵌套组件额外检查**
- [ ] **子组件核心层** - 每个功能区域都必须有 `index.[ext]` 文件
- [ ] **父子协调** - 父组件必须正确导入和使用子组件
- [ ] **类型统一** - 父组件 `types.[ext]` 必须导出所有子组件相关类型
- [ ] **常量集中** - 父组件 `constants.[ext]` 必须导出所有子组件相关常量

#### 🚫 **完整结构违规行为**

##### ❌ **严重违规 (架构验证失败)**
1. **缺少核心文件** - 缺少 `index.[ext]`、`types.[ext]`、`constants.[ext]`、`README.md`
2. **职责混合** - 将多个层级的职责混合在一个文件中
3. **API接口不配套** - 创建了 `api*.[ext]` 但没有对应的 `backend/` 文件夹
4. **类型定义缺失** - 缺少必要的接口和类型定义
5. **常量硬编码** - 在代码中硬编码常量而不提取到 `constants.[ext]`

##### ⚠️ **一般违规 (功能不完整)**
1. **功能文件缺失** - 有相关功能但缺少对应的功能文件
2. **命名不规范** - 文件命名不符合规范要求
3. **文档不完整** - `README.md` 缺少必要的使用说明
4. **嵌套结构不合理** - 子组件边界与功能区域不对应

#### 💡 **完整结构最佳实践**

##### 🎯 **创建顺序建议**
1. **第一步**: 创建核心文件层 (必需文件)
2. **第二步**: 分析功能需求，确定需要的功能层
3. **第三步**: 按功能层级逐层创建文件
4. **第四步**: 对于复杂组件，规划子组件结构
5. **第五步**: 实施完整性验证检查

##### 🔄 **渐进式完善策略**
```
完整结构实施 = 架构完整 + 实现渐进

第一阶段: 创建完整的文件结构框架
├── 所有必需文件 (index, types, constants, README)
├── 所有按需文件 (根据功能需求)
└── 完整的目录层次结构

第二阶段: 实施 YAGNI + MVP 代码填充
├── 每个文件只实现当前需要的功能
├── 避免过度设计和预先优化
└── 保持代码简洁和可读性

第三阶段: 根据实际需求渐进式完善
├── 功能扩展时补充对应文件内容
├── 重构时保持架构结构不变
└── 持续优化和改进代码质量
```

#### 🎨 **完整结构实施示例对比**

##### ✅ **正确的完整结构实施**
```
UserCard/ (复杂组件 - 嵌套化)
├── index.tsx ✓ 主组件存在
├── types.ts ✓ 类型定义完整
├── constants.ts ✓ 常量提取完整
├── useUserCard.ts ✓ 主状态管理
├── README.md ✓ 文档完整
│
├── AvatarArea/ ✓ 功能区域清晰
│   ├── index.tsx ✓ 区域主文件
│   ├── constants.ts ✓ 区域常量
│   └── onAvatarClick.ts ✓ 区域事件
│
├── ProfileInfoArea/ ✓ 功能区域清晰
│   ├── index.tsx ✓ 区域主文件
│   ├── types.ts ✓ 区域类型
│   └── formatProfileDisplay.ts ✓ 区域工具
│
└── ActionButtonsArea/ ✓ 功能区域清晰
    ├── index.tsx ✓ 区域主文件
    ├── useActionButtons.ts ✓ 区域状态
    ├── onFollowClick.ts ✓ 区域事件
    └── apiUserFollow.ts ✓ 区域API
```

##### ❌ **错误的不完整实施**
```
UserCard/ (违规示例)
├── UserCard.tsx ❌ 文件名不规范 (应该是 index.tsx)
├── types.ts ✓ 类型定义存在
├── [缺少 constants.ts] ❌ 缺少常量定义文件
├── [缺少 README.md] ❌ 缺少文档文件
│
├── Avatar.tsx ❌ 应该是文件夹结构 (Avatar/)
├── Profile.tsx ❌ 应该是文件夹结构 (ProfileInfoArea/)
├── Actions.tsx ❌ 应该是文件夹结构 (ActionButtonsArea/)
│
└── utils.ts ❌ 职责混合，应该拆分为具体功能文件
```

## 📋 通用命名规范体系

### 🏷️ 核心文件命名

| 文件类型 | 命名格式 | 职责描述 |
|---------|---------|----------|
| **主组件** | `index.[ext]` | 组件的主要UI实现和功能组装 |
| **类型定义** | `types.[ext]` | 数据结构、接口、类型定义 |
| **常量定义** | `constants.[ext]` | 组件相关的常量配置 |
| **组件文档** | `README.md` | 组件使用说明和API文档 |

### 🏗️ 主组件文件详细构成

#### 📋 主组件文件 (`index.[ext]`) 的核心职责
- **UI渲染逻辑** - 组件的视觉呈现和布局结构
- **功能模块组装** - 整合状态管理、事件处理、导航等模块
- **Props接口实现** - 实现对外暴露的属性接口
- **生命周期管理** - 处理组件的初始化、更新、销毁
- **条件渲染控制** - 根据状态控制不同UI的显示
- **样式应用** - 组件的样式定义和应用

#### 🔧 主组件文件的典型结构层次

```
主组件文件 (index.[ext])
│
├── 📦 导入声明区域
│   ├── 框架核心导入 (React, Vue, Angular等)
│   ├── UI组件库导入 (Button, Input, Modal等)
│   ├── 内部类型导入 (./types)
│   ├── 内部常量导入 (./constants)
│   ├── 状态管理导入 (./use[ComponentName]*)
│   ├── 事件处理导入 (./on[ComponentName]*)
│   ├── 导航处理导入 (./navigateTo*)
│   ├── API接口导入 (./api[ComponentName]*)
│   └── 工具函数导入 (./format*, ./process*等)
│
├── 🎯 组件定义区域
│   ├── Props接口接收
│   ├── Props默认值设置
│   └── Props解构和验证
│
├── 🔄 状态管理区域
│   ├── 主状态管理 (use[ComponentName])
│   ├── 功能状态管理 (use[ComponentName][Feature])
│   ├── 表单状态管理 (use[ComponentName]Form)
│   └── 数据状态管理 (use[ComponentName]Data)
│
├── ⚡ 事件处理区域
│   ├── 用户交互事件封装
│   ├── 表单提交事件封装
│   ├── 导航跳转事件封装
│   └── API调用事件封装
│
├── 🧮 计算属性区域
│   ├── 数据处理和转换
│   ├── 格式化显示逻辑
│   ├── 条件判断逻辑
│   └── 派生状态计算
│
├── 🎨 渲染逻辑区域
│   ├── 加载状态渲染
│   ├── 错误状态渲染
│   ├── 空状态渲染
│   └── 主要内容渲染
│
├── 💅 样式定义区域
│   ├── 容器样式
│   ├── 内容样式
│   ├── 交互样式
│   └── 状态样式
│
└── 📤 导出声明区域
    ├── 主组件导出
    └── 类型接口导出
```

#### 🎭 主组件文件的可能构成模式

##### 🟢 简单展示型组件构成
```
简单组件 (index.[ext])
├── 基础导入 (框架 + 内部types)
├── Props接收
├── 基础渲染逻辑
├── 简单样式定义
└── 组件导出
```

##### 🟡 交互型组件构成
```
交互组件 (index.[ext])
├── 扩展导入 (+ 状态管理 + 事件处理)
├── Props接收和验证
├── 状态管理 (1-2个hooks)
├── 事件处理封装 (2-3个事件)
├── 条件渲染逻辑
├── 完整样式定义
└── 组件和类型导出
```

##### 🔴 复杂业务型组件构成
```
复杂组件 (index.[ext])
├── 完整导入 (框架 + 所有内部模块)
├── Props接收、验证、默认值
├── 多层状态管理 (3-5个hooks)
├── 完整事件处理 (5-8个事件)
├── API调用集成
├── 数据处理和计算
├── 多状态条件渲染
├── 完整样式系统
└── 完整导出接口
```

#### 📐 主组件文件的设计原则

| 原则 | 说明 | 实现方式 |
|------|------|----------|
| **单一入口** | 作为组件功能的唯一入口点 | 所有外部调用都通过主组件 |
| **功能组装** | 整合各个功能模块，而非实现具体逻辑 | 导入并调用各个功能模块 |
| **接口实现** | 实现对外承诺的Props接口 | 严格按照types定义实现 |
| **状态协调** | 协调不同状态管理模块 | 合理组合多个state hooks |
| **UI控制** | 控制组件的视觉呈现和交互 | 负责渲染逻辑和样式应用 |
| **错误边界** | 处理组件级别的错误状态 | 实现错误状态的UI展示 |

#### 🔄 主组件文件与其他文件的协作关系

```
主组件 (index.[ext])
    ↓ 导入使用
┌── types.[ext] ──────────── 提供类型定义和接口约束
├── constants.[ext] ──────── 提供常量配置和默认值
├── use[ComponentName]* ──── 提供状态管理和业务逻辑
├── on[ComponentName]* ───── 提供事件处理和用户交互
├── navigateTo* ─────────── 提供页面跳转和路由导航
├── api[ComponentName]* ─── 提供数据获取和接口调用
├── process[ComponentName]* - 提供数据处理和转换逻辑
└── format[ComponentName]* - 提供格式化和工具函数
    ↓ 组合调用
主组件渲染输出 → 对外提供完整的组件功能
```

#### 📦 页面组件导入使用方式

**使用 index 主文件的优势**：

```typescript
// ✅ 推荐：直接导入组件（通过 index 文件）
import UserCard from './UserCard';
import WaterfallCard from './WaterfallCard';
import TabBar from './TabBar';

// 使用时非常明确
<UserCard id="123" name="张三" />
<WaterfallCard data={cardData} />
<TabBar activeTab={currentTab} />
```

**index 文件的导入优势**：

```typescript
// ✅ 推荐：使用 index 文件（简洁明确）
import UserCard from './UserCard';           // 自动导入 ./UserCard/index.tsx
import WaterfallCard from './WaterfallCard'; // 自动导入 ./WaterfallCard/index.tsx
import TabBar from './TabBar';               // 自动导入 ./TabBar/index.tsx

// 也可以显式指定 index 文件
import UserCard from './UserCard/index';     // 明确指定 index 文件
import WaterfallCard from './WaterfallCard/index';
```

**index 文件的优势**：
- **简洁的导入路径** - 无需指定具体文件名，自动解析 index
- **IDE 支持更好** - 自动补全和跳转准确定位到 index 文件
- **调试更方便** - 错误信息明确显示来自 index 文件
- **重构更安全** - 组件内部重构不影响外部导入路径

#### 💡 主组件文件的最佳实践

##### ✅ 应该做的 (DO)
- **保持主组件的简洁性** - 主要负责组装和渲染
- **合理使用内部模块** - 充分利用拆分出的功能文件
- **提供完整的错误处理** - 处理各种异常状态
- **保持Props接口的稳定** - 避免频繁变更对外接口
- **添加适当的注释** - 说明复杂的渲染逻辑

##### ❌ 避免做的 (DON'T)
- **在主组件中写复杂业务逻辑** - 应拆分到对应的功能文件
- **硬编码常量和配置** - 应提取到constants文件
- **混合多种职责** - 避免在渲染逻辑中处理数据
- **忽略错误状态** - 必须处理加载、错误、空状态
- **过度复杂的条件渲染** - 复杂逻辑应提取到计算属性

## 🔌 MyBatis Plus 后端架构详细说明

### 📁 后端文件夹结构

```
ComponentName/backend/                              # 后端代码专用文件夹
├── entity[ComponentName].java                      # 实体类 - MP注解数据模型
├── dto[ComponentName][Action].java                 # 数据传输对象 - 请求响应结构
├── controller[ComponentName].java                  # 控制器 - REST API接口
├── service[ComponentName].java                     # 业务服务 - QueryWrapper业务逻辑
├── mapper[ComponentName].java                      # 数据访问接口 - 仅在需要特殊查询时
└── sql[ComponentName].xml                          # 复杂SQL查询 - 仅在极复杂SQL时
```

### 🏗️ Entity 实体类构成 (MyBatis Plus)

#### 📊 实体类必要组成部分

```
Entity实体类 (entity[ComponentName].java)
├── 🏷️ 类注解
│   ├── @TableName("table_name") - 表名映射
│   ├── @Data - Lombok数据注解
│   ├── @Builder - 建造者模式
│   └── @AllArgsConstructor/@NoArgsConstructor - 构造函数
│
├── 🆔 主键字段
│   ├── @TableId(type = IdType.AUTO) - 自增主键
│   ├── private Long id - 主键ID
│   └── private String uuid - 全局唯一标识(可选)
│
├── 📝 业务字段
│   ├── @TableField("column_name") - 字段映射
│   ├── private String name - 业务名称
│   ├── private String title - 标题
│   ├── private String content - 内容
│   ├── private Integer status - 状态字段
│   └── private String type - 类型分类
│
├── 🔗 关联字段
│   ├── private Long userId - 用户ID外键
│   ├── private Long parentId - 父级ID
│   ├── @TableField(exist = false) - 非数据库字段
│   └── private List<SubEntity> children - 关联集合
│
├── 📅 时间字段
│   ├── @TableField(fill = FieldFill.INSERT) - 插入时填充
│   ├── private LocalDateTime createdAt - 创建时间
│   ├── @TableField(fill = FieldFill.INSERT_UPDATE) - 插入更新时填充
│   ├── private LocalDateTime updatedAt - 更新时间
│   └── private LocalDateTime deletedAt - 软删除时间
│
├── 👤 操作字段
│   ├── private Long createdBy - 创建人ID
│   ├── private Long updatedBy - 更新人ID
│   └── private Long ownerId - 所有者ID
│
└── 🏷️ 扩展字段
    ├── @TableField(typeHandler = JsonTypeHandler.class) - JSON处理
    ├── private Map<String, Object> metadata - 元数据
    ├── private List<String> tags - 标签列表
    └── private String extra - 扩展信息
```

### 📨 DTO 数据传输对象构成

#### 🎯 DTO 文件标准结构

```
DTO文件 (dto[ComponentName][Action].java)
├── 📥 请求DTO类
│   ├── @Data @Builder - Lombok注解
│   ├── @Valid - 验证注解
│   ├── CreateRequest - 创建请求
│   │   ├── @NotBlank private String name
│   │   ├── @NotNull private String title
│   │   └── private Map<String, Object> metadata
│   ├── UpdateRequest - 更新请求
│   │   ├── @NotNull private Long id
│   │   ├── private String name
│   │   └── private Integer status
│   ├── QueryRequest - 查询请求
│   │   ├── private String keyword
│   │   ├── private Integer status
│   │   ├── private LocalDateTime startTime
│   │   └── private LocalDateTime endTime
│   └── BatchRequest - 批量请求
│       ├── @NotEmpty private List<Long> ids
│       └── private Integer batchStatus
│
├── 📤 响应DTO类
│   ├── DetailResponse - 详情响应
│   │   ├── private Long id
│   │   ├── private String name
│   │   ├── private UserInfo userInfo
│   │   └── private LocalDateTime createdAt
│   ├── ListResponse - 列表响应
│   │   ├── private Long id
│   │   ├── private String name
│   │   ├── private Integer status
│   │   └── private String summary
│   └── PageResponse<T> - 分页响应
│       ├── private List<T> records
│       ├── private Long total
│       ├── private Long current
│       └── private Long size
│
└── 🏷️ 基础类型
    ├── PageRequest - 分页请求
    │   ├── private Long current = 1L
    │   ├── private Long size = 10L
    │   ├── private String orderBy
    │   └── private Boolean isAsc = true
    └── BaseResponse<T> - 统一响应
        ├── private Integer code
        ├── private String message
        ├── private T data
        └── private Long timestamp
```

### 🎮 Controller 控制器构成

#### 🔧 控制器标准结构

```
Controller (controller[ComponentName].java)
├── 🏷️ 类注解
│   ├── @RestController - REST控制器
│   ├── @RequestMapping("/api/usercard") - 路由前缀
│   ├── @Api(tags = "用户卡片管理") - Swagger文档
│   └── @Validated - 参数验证
│
├── 🔗 依赖注入
│   ├── @Autowired private UserCardService userCardService
│   └── @Resource private RedisTemplate redisTemplate
│
├── 📊 CRUD接口
│   ├── @PostMapping("/create") - 创建
│   │   ├── @ApiOperation("创建用户卡片")
│   │   ├── public BaseResponse<Long> create(
│   │   ├──     @Valid @RequestBody CreateRequest request)
│   │   └── return userCardService.create(request)
│   │
│   ├── @GetMapping("/{id}") - 查询详情
│   │   ├── @ApiOperation("获取用户卡片详情")
│   │   ├── public BaseResponse<DetailResponse> getById(
│   │   ├──     @PathVariable Long id)
│   │   └── return userCardService.getById(id)
│   │
│   ├── @PutMapping("/update") - 更新
│   │   ├── @ApiOperation("更新用户卡片")
│   │   ├── public BaseResponse<Boolean> update(
│   │   ├──     @Valid @RequestBody UpdateRequest request)
│   │   └── return userCardService.update(request)
│   │
│   └── @DeleteMapping("/{id}") - 删除
│       ├── @ApiOperation("删除用户卡片")
│       ├── public BaseResponse<Boolean> delete(
│       ├──     @PathVariable Long id)
│       └── return userCardService.delete(id)
│
├── 📋 查询接口
│   ├── @GetMapping("/list") - 列表查询
│   │   ├── public BaseResponse<PageResponse<ListResponse>> list(
│   │   ├──     @Valid QueryRequest request,
│   │   ├──     PageRequest pageRequest)
│   │   └── return userCardService.list(request, pageRequest)
│   │
│   └── @GetMapping("/search") - 搜索接口
│       ├── @ApiOperation("搜索用户卡片")
│       ├── public BaseResponse<List<ListResponse>> search(
│       ├──     @RequestParam String keyword)
│       └── return userCardService.search(keyword)
│
└── 🔄 批量接口
    ├── @PostMapping("/batch/create") - 批量创建
    ├── @PutMapping("/batch/update") - 批量更新
    └── @DeleteMapping("/batch/delete") - 批量删除
```

### 🔧 Service 业务服务构成 (QueryWrapper)

#### 🎯 Service 标准结构

```
Service (service[ComponentName].java)
├── 🏷️ 类注解
│   ├── @Service - 服务注解
│   ├── @Transactional - 事务管理
│   └── @Slf4j - 日志注解
│
├── 🔗 依赖注入
│   ├── @Autowired private UserCardMapper userCardMapper
│   ├── @Autowired private RedisTemplate redisTemplate
│   └── @Resource private UserService userService
│
├── 📊 CRUD方法 (使用QueryWrapper)
│   ├── public Long create(CreateRequest request)
│   │   ├── // 数据验证和转换
│   │   ├── UserCard entity = convertToEntity(request)
│   │   ├── // 设置创建信息
│   │   ├── entity.setCreatedAt(LocalDateTime.now())
│   │   ├── // 保存到数据库
│   │   ├── userCardMapper.insert(entity)
│   │   └── return entity.getId()
│   │
│   ├── public DetailResponse getById(Long id)
│   │   ├── // 构建查询条件
│   │   ├── QueryWrapper<UserCard> wrapper = new QueryWrapper<>()
│   │   ├──     .eq("id", id)
│   │   ├──     .eq("deleted_at", null)
│   │   ├── UserCard entity = userCardMapper.selectOne(wrapper)
│   │   └── return convertToDetailResponse(entity)
│   │
│   ├── public Boolean update(UpdateRequest request)
│   │   ├── // 构建更新条件
│   │   ├── UpdateWrapper<UserCard> wrapper = new UpdateWrapper<>()
│   │   ├──     .eq("id", request.getId())
│   │   ├──     .set("updated_at", LocalDateTime.now())
│   │   ├── // 动态更新字段
│   │   ├── if (request.getName() != null) wrapper.set("name", request.getName())
│   │   ├── if (request.getStatus() != null) wrapper.set("status", request.getStatus())
│   │   └── return userCardMapper.update(null, wrapper) > 0
│   │
│   └── public Boolean delete(Long id)
│       ├── // 软删除实现
│       ├── UpdateWrapper<UserCard> wrapper = new UpdateWrapper<>()
│       ├──     .eq("id", id)
│       ├──     .set("deleted_at", LocalDateTime.now())
│       └── return userCardMapper.update(null, wrapper) > 0
│
├── 📋 查询方法 (复杂QueryWrapper)
│   ├── public PageResponse<ListResponse> list(QueryRequest request, PageRequest pageRequest)
│   │   ├── // 构建复杂查询条件
│   │   ├── QueryWrapper<UserCard> wrapper = new QueryWrapper<UserCard>()
│   │   ├──     .like(StringUtils.isNotBlank(request.getKeyword()), "name", request.getKeyword())
│   │   ├──     .eq(request.getStatus() != null, "status", request.getStatus())
│   │   ├──     .between(request.getStartTime() != null && request.getEndTime() != null,
│   │   ├──         "created_at", request.getStartTime(), request.getEndTime())
│   │   ├──     .orderByDesc("created_at")
│   │   ├── // 分页查询
│   │   ├── Page<UserCard> page = new Page<>(pageRequest.getCurrent(), pageRequest.getSize())
│   │   ├── IPage<UserCard> result = userCardMapper.selectPage(page, wrapper)
│   │   └── return convertToPageResponse(result)
│   │
│   └── public List<ListResponse> search(String keyword)
│       ├── // 全文搜索QueryWrapper
│       ├── QueryWrapper<UserCard> wrapper = new QueryWrapper<UserCard>()
│       ├──     .and(w -> w.like("name", keyword)
│       ├──         .or().like("title", keyword)
│       ├──         .or().like("content", keyword))
│       ├──     .eq("status", 1)
│       ├──     .orderByDesc("created_at")
│       ├──     .last("LIMIT 50")
│       └── return convertToListResponse(userCardMapper.selectList(wrapper))
│
└── 🔄 批量方法
    ├── public Boolean batchCreate(List<CreateRequest> requests)
    │   ├── List<UserCard> entities = requests.stream()
    │   ├──     .map(this::convertToEntity).collect(Collectors.toList())
    │   └── return userCardService.saveBatch(entities)
    │
    └── public Boolean batchUpdateStatus(List<Long> ids, Integer status)
        ├── UpdateWrapper<UserCard> wrapper = new UpdateWrapper<UserCard>()
        ├──     .in("id", ids)
        ├──     .set("status", status)
        ├──     .set("updated_at", LocalDateTime.now())
        └── return userCardMapper.update(null, wrapper) > 0
```

### 🗺️ Mapper 数据访问层构成 (QueryWrapper 简化版)

#### 🎯 QueryWrapper 时代的 Mapper 定位

**使用 QueryWrapper 后，大部分场景下 Mapper 层可以极度简化！**

#### 🔄 简化的 Mapper 接口结构

```
Mapper (mapper[ComponentName].java) - 可选文件
├── 🏷️ 最小接口注解
│   ├── @Mapper - MyBatis映射器
│   └── @Repository - 仓储注解(可选)
│
├── 🔗 仅继承BaseMapper (核心)
│   └── public interface UserCardMapper extends BaseMapper<UserCard>
│   // 这一行代码就获得了所有基础CRUD方法！
│   // insert(), selectById(), updateById(), deleteById()
│   // selectList(), selectPage(), selectCount()等
│
├── 📊 特殊场景自定义方法 (仅在必要时添加)
│   ├── // 极复杂的关联查询 (QueryWrapper难以处理)
│   ├── @Select("SELECT uc.*, u.username, p.profile_url " +
│   ├──         "FROM user_card uc " +
│   ├──         "LEFT JOIN user u ON uc.user_id = u.id " +
│   ├──         "LEFT JOIN user_profile p ON u.id = p.user_id " +
│   ├──         "WHERE uc.id = #{id}")
│   ├── UserCardDetailVO getDetailWithUserProfile(@Param("id") Long id)
│   │
│   ├── // 原生SQL性能优化查询
│   ├── @Select("SELECT * FROM user_card USE INDEX(idx_status_created) " +
│   ├──         "WHERE status = #{status} ORDER BY created_at DESC LIMIT #{limit}")
│   ├── List<UserCard> selectByStatusOptimized(@Param("status") Integer status, @Param("limit") Integer limit)
│   │
│   └── // 存储过程调用 (特殊业务场景)
│       ├── @Select("{CALL proc_user_card_statistics(#{userId})}")
│       └── Map<String, Object> getUserCardStatistics(@Param("userId") Long userId)
│
└── 💡 QueryWrapper 替代说明
    ├── // ❌ 不再需要这些方法 (QueryWrapper可以完美处理)
    ├── // List<UserCard> selectByName(String name)  
    ├── // ✅ 用 QueryWrapper 替代: 
    ├── // wrapper.eq("name", name)
    ├── 
    ├── // ❌ 不再需要这些方法
    ├── // List<UserCard> selectByStatusAndTime(Integer status, LocalDateTime start, LocalDateTime end)
    ├── // ✅ 用 QueryWrapper 替代:
    ├── // wrapper.eq("status", status).between("created_at", start, end)
    ├──
    ├── // ❌ 不再需要这些方法  
    ├── // int updateStatusById(Long id, Integer status)
    ├── // ✅ 用 UpdateWrapper 替代:
    └── // updateWrapper.eq("id", id).set("status", status)
```

#### 🚀 Service 层直接使用 BaseMapper + QueryWrapper

```
Service中的典型用法 (service[ComponentName].java)
├── 🔗 注入简化的Mapper
│   └── @Autowired private UserCardMapper userCardMapper;
│
├── 📊 QueryWrapper 替代复杂查询
│   ├── // 代替原来需要写在Mapper中的复杂方法
│   ├── public List<UserCard> findByComplexCondition(String keyword, Integer status, LocalDateTime start) {
│   ├──     QueryWrapper<UserCard> wrapper = new QueryWrapper<UserCard>()
│   ├──         .like(StringUtils.isNotBlank(keyword), "name", keyword)
│   ├──         .or().like(StringUtils.isNotBlank(keyword), "title", keyword)
│   ├──         .eq(status != null, "status", status)
│   ├──         .ge(start != null, "created_at", start)
│   ├──         .orderByDesc("created_at");
│   ├──     return userCardMapper.selectList(wrapper);
│   └── }
│
├── 🔄 UpdateWrapper 替代复杂更新
│   ├── public Boolean batchUpdateStatus(List<Long> ids, Integer status) {
│   ├──     UpdateWrapper<UserCard> wrapper = new UpdateWrapper<UserCard>()
│   ├──         .in("id", ids)
│   ├──         .set("status", status)
│   ├──         .set("updated_at", LocalDateTime.now());
│   ├──     return userCardMapper.update(null, wrapper) > 0;
│   └── }
│
└── 📈 分页查询也在Service中处理
    ├── public IPage<UserCard> getPageList(QueryRequest request, Long current, Long size) {
    ├──     Page<UserCard> page = new Page<>(current, size);
    ├──     QueryWrapper<UserCard> wrapper = new QueryWrapper<UserCard>()
    ├──         .like(StringUtils.isNotBlank(request.getKeyword()), "name", request.getKeyword())
    ├──         .eq(request.getStatus() != null, "status", request.getStatus())
    ├──         .orderByDesc("created_at");
    ├──     return userCardMapper.selectPage(page, wrapper);
    └── }
```

#### 💡 是否需要 Mapper 文件的判断标准

| 场景 | 是否需要 Mapper | 说明 |
|------|----------------|------|
| **简单 CRUD** | ❌ 不需要 | BaseMapper 已提供所有基础方法 |
| **条件查询** | ❌ 不需要 | QueryWrapper 可以处理 99% 的条件查询 |
| **分页查询** | ❌ 不需要 | `selectPage(page, wrapper)` 完美支持 |
| **批量操作** | ❌ 不需要 | `saveBatch()`, UpdateWrapper 批量更新 |
| **统计查询** | ❌ 不需要 | `selectCount(wrapper)` 可以处理大部分统计 |
| **复杂关联查询** | ✅ 可能需要 | 3表以上关联，QueryWrapper 难以处理 |
| **性能优化查询** | ✅ 可能需要 | 需要使用索引提示、原生 SQL 优化 |
| **存储过程调用** | ✅ 需要 | QueryWrapper 无法处理存储过程 |
| **复杂业务SQL** | ✅ 可能需要 | 特殊的业务逻辑 SQL |

### 🎣 状态管理命名

| 功能类型 | 命名格式 | 示例 | 职责 |
|---------|---------|------|------|
| **主状态管理** | `use[ComponentName].[ext]` | `useUserCard.[ext]` | 组件核心状态逻辑 |
| **功能状态** | `use[ComponentName][Feature].[ext]` | `useUserCardAnimation.[ext]` | 特定功能状态管理 |
| **数据状态** | `use[ComponentName][DataSource].[ext]` | `useUserCardData.[ext]` | 数据获取和管理 |
| **表单状态** | `use[ComponentName][Form].[ext]` | `useUserCardForm.[ext]` | 表单状态管理 |

### 🎯 事件处理命名 (专注用户操作)

| 事件类型 | 命名格式 | 示例 | 职责 |
|---------|---------|------|------|
| **基础交互** | `on[ComponentName][Action].[ext]` | `onUserCardClick.[ext]` | 处理基础用户操作 (点击、输入) |
| **复杂操作** | `on[ComponentName][UserAction].[ext]` | `onUserCardLongPress.[ext]` | 处理复杂用户操作 (长按、滑动) |
| **表单操作** | `on[ComponentName][FormAction].[ext]` | `onUserCardSubmit.[ext]` | 处理表单相关操作 |
| **多步操作** | `on[ComponentName][FlowAction].[ext]` | `onUserCardConfirm.[ext]` | 处理多步骤用户操作 |

### 🧭 导航处理命名

| 导航类型 | 命名格式 | 示例 | 职责 |
|---------|---------|------|------|
| **页面跳转** | `navigateTo[Target].[ext]` | `navigateToProfile.[ext]` | 跳转到目标页面 |
| **返回导航** | `navigateBack[Source].[ext]` | `navigateBackFromProfile.[ext]` | 从当前页面返回 |
| **流程导航** | `navigate[ComponentName][Flow].[ext]` | `navigateUserCardFlow.[ext]` | 多步骤流程导航 |
| **条件导航** | `navigateIf[Condition].[ext]` | `navigateIfLoggedIn.[ext]` | 条件性导航跳转 |

### 🌐 API接口处理命名

| 接口类型 | 命名格式 | 示例 | 职责 |
|---------|---------|------|------|
| **基础接口** | `api[ComponentName][Action].[ext]` | `apiUserCardFetch.[ext]` | 基础数据获取接口 |
| **数据源接口** | `api[ComponentName][DataSource].[ext]` | `apiUserCardProfile.[ext]` | 特定数据源接口 |
| **操作接口** | `api[ComponentName][Operation].[ext]` | `apiUserCardUpdate.[ext]` | 数据操作接口 (增删改) |
| **批量接口** | `api[ComponentName][Batch].[ext]` | `apiUserCardBatchLoad.[ext]` | 批量操作接口 |

### 🔌 后端交互层命名 (MyBatis Plus + QueryWrapper 架构)

| 交互类型 | 命名格式 | 示例 | 职责 | 使用场景 |
|---------|---------|------|------|----------|
| **实体类** | `entity[ComponentName].[ext]` | `entityUserCard.java` | 数据模型和业务实体定义 (MP注解) | ✅ 必需 |
| **数据传输对象** | `dto[ComponentName][Action].[ext]` | `dtoUserCardRequest.java` | 请求响应数据结构 | ✅ 必需 |
| **控制器** | `controller[ComponentName].[ext]` | `controllerUserCard.java` | REST API接口和路由定义 | ✅ 必需 |
| **业务服务** | `service[ComponentName].[ext]` | `serviceUserCard.java` | 业务逻辑封装 (主要使用QueryWrapper) | ✅ 必需 |
| **数据访问接口** | `mapper[ComponentName].[ext]` | `mapperUserCard.java` | 数据访问接口 | 🟡 仅在需要特殊查询时 |
| **复杂SQL配置** | `sql[ComponentName].xml` | `sqlUserCard.xml` | 复杂SQL查询配置 | 🟡 仅在极复杂SQL时 |

### 🔄 数据处理命名

| 处理类型 | 命名格式 | 示例 | 职责 |
|---------|---------|------|------|
| **数据处理** | `process[ComponentName][Data].[ext]` | `processUserCardData.[ext]` | 原始数据处理 |
| **数据转换** | `transform[ComponentName][Format].[ext]` | `transformUserCardFormat.[ext]` | 数据格式转换 |
| **数据验证** | `validate[ComponentName][Input].[ext]` | `validateUserCardInput.[ext]` | 输入数据验证 |
| **数据过滤** | `filter[ComponentName][Criteria].[ext]` | `filterUserCardList.[ext]` | 数据筛选过滤 |

### 🛠️ 工具函数命名

| 工具类型 | 命名格式 | 示例 | 职责 |
|---------|---------|------|------|
| **格式化** | `format[ComponentName][Display].[ext]` | `formatUserCardDisplay.[ext]` | 显示格式化 |
| **计算逻辑** | `calculate[ComponentName][Value].[ext]` | `calculateUserCardScore.[ext]` | 数值计算逻辑 |
| **动画逻辑** | `animate[ComponentName][Transition].[ext]` | `animateUserCardTransition.[ext]` | 动画过渡效果 |
| **工具函数** | `[verb][ComponentName][Object].[ext]` | `sortUserCardList.[ext]` | 通用工具函数 |

## 🏗️ 扁平化目录结构说明

### 📦 组件根目录 (扁平化组织)
   ```
   ComponentName/                          # 组件名称，使用PascalCase
   ├── index.[ext]                         # 主组件实现 (必需)
   ├── types.[ext]                         # 类型定义 (必需)
   ├── constants.[ext]                     # 常量配置 (可选)
   ├── README.md                          # 文档说明 (推荐)
│
├── use[ComponentName]*.[ext]           # 状态管理相关文件
├── on[ComponentName]*.[ext]            # 用户操作事件相关文件
├── navigateTo*.[ext]                   # 导航处理相关文件
├── api[ComponentName]*.[ext]           # API接口相关文件
├── process[ComponentName]*.[ext]       # 数据处理相关文件
└── format[ComponentName]*.[ext]        # 工具函数相关文件
```

### 🎯 按功能前缀组织
```
ComponentName/
├── {ComponentName}.[ext]               # 主组件 (UI渲染和组装)
├── types.[ext]                         # 类型定义
├── constants.[ext]                     # 常量配置
│
├── use[ComponentName]*.[ext]           # 状态管理 (use前缀)
├── on[ComponentName]*.[ext]            # 用户事件 (on前缀)  
├── navigateTo*.[ext]                   # 导航处理 (navigate前缀)
├── api[ComponentName]*.[ext]           # 接口调用 (api前缀)
├── process[ComponentName]*.[ext]       # 数据处理 (process前缀)
└── format[ComponentName]*.[ext]        # 工具函数 (format/calculate等前缀)
```

### 🔗 扁平化依赖关系
```
主组件 ({ComponentName}.[ext])
    ↓ 直接导入
状态管理 (use*) + 用户事件 (on*) + 导航 (navigate*) + 接口 (api*)
    ↓ 可能依赖  
数据处理 (process*) + 工具函数 (format*等)
    ↓ 基础依赖
类型定义 (types) + 常量配置 (constants)
```
---

## 🤖 Agent 重构操作指南

### 📋 重构执行步骤

#### 1️⃣ 分析阶段 (必须执行)
```
✅ 分析现有组件的所有功能模块
✅ 识别所有需要拆分的逻辑模块
✅ 列出需要创建的完整文件清单
✅ 规划完整的架构结构 (不允许简化)
```

#### 2️⃣ 创建阶段 (按顺序执行)
```
1. 创建组件根目录 ComponentName/
2. 创建核心文件：
   ✅ index.[ext] - 主组件文件
   ✅ types.[ext] - 类型定义文件
   ✅ constants.[ext] - 常量定义文件
   ✅ README.md - 组件文档文件
3. 根据复杂度创建功能文件：
   ✅ use[ComponentName]*.[ext] - 状态管理文件
   ✅ on[ComponentName]*.[ext] - 事件处理文件
   ✅ navigateTo*.[ext] - 导航处理文件
   ✅ api[ComponentName]*.[ext] - API接口文件（与backend/配套）
   ✅ backend/ - 后端交互文件夹（与api*配套，必须同时创建）
   ✅ process[ComponentName]*.[ext] - 数据处理文件
   ✅ format[ComponentName]*.[ext] - 工具函数文件
```

#### 3️⃣ 重构阶段 (逐文件执行 - 遵循 YAGNI + MVP)
```
✅ 将原组件代码按职责拆分到对应文件
✅ 提取所有类型定义到 types.[ext] (仅当前需要的类型)
✅ 提取所有常量到 constants.[ext] (仅当前使用的常量)
✅ 拆分状态管理逻辑到 use*.[ext] (最小可用状态管理)
✅ 拆分事件处理逻辑到 on*.[ext] (核心事件处理)
✅ 拆分导航逻辑到 navigate*.[ext] (基础导航功能)
✅ 拆分API调用到 api*.[ext] (核心API接口，配套backend/)
✅ 创建完整后端交互层 backend/ (最小可用后端实现)
✅ 拆分数据处理到 process*.[ext] (基础数据处理)
✅ 重构主组件 index 文件，整合各模块 (简洁的组装逻辑)

🎯 重构原则：架构完整 + 实现简洁 (YAGNI + MVP)
```

#### 4️⃣ 验证阶段 (质量检查)
```
✅ 检查文件命名是否符合规范
✅ 检查每个文件职责是否单一
✅ 检查类型定义是否完整
✅ 检查导入导出是否正确
✅ 检查是否有遗漏的功能模块
✅ 编写完整的 README.md 文档
```

### 🎯 重构质量标准

#### ✅ 合格标准
- [x] 所有文件命名符合规范
- [x] 每个文件职责单一明确
- [x] 类型定义完整准确
- [x] 常量全部提取
- [x] 主组件 index 文件简洁清晰
- [x] 提供完整的使用文档
- [x] 错误处理完善

#### 🚫 不合格表现
- [ ] 文件命名模糊不清
- [ ] 多个职责混合在一个文件
- [ ] 缺少类型定义
- [ ] 硬编码常量
- [ ] 主组件过于复杂
- [ ] 缺少使用文档
- [ ] 忽略错误处理

### 📝 重构报告模板

**Agent 完成重构后必须提供以下报告：**

```markdown
## 🔧 组件重构报告

### 📊 重构概况
- **组件名称**: ComponentName
- **架构标准**: 完整结构 (统一标准)
- **创建文件数**: X 个
- **重构前文件数**: Y 个

### 📁 文件结构
```
ComponentName/
├── index.[ext]                 # 主组件 - [功能描述]
├── types.[ext]                 # 类型定义 - [包含类型数量]
├── constants.[ext]             # 常量定义 - [常量数量]
├── [其他文件...]
└── README.md                   # 使用文档
```

### 🔧 重构内容
1. **类型定义拆分**: 提取了 X 个类型定义
2. **常量提取**: 提取了 Y 个常量
3. **状态管理**: 拆分了 Z 个状态管理模块
4. **事件处理**: 拆分了 W 个事件处理模块
5. **[其他拆分内容...]**

### 📋 质量检查
- [x] 文件命名规范 ✅
- [x] 职责单一性 ✅
- [x] 类型完整性 ✅
- [x] 文档完整性 ✅

### 🎯 使用方式
[提供重构后组件的使用示例]
```

**🚨 强制要求：Agent 必须严格按照本文档的完整架构标准执行重构，不得省略任何步骤，不得简化任何结构！**

---

## 🔄 伪页面组件迁移指南

### 📋 从 components/ 层级迁移到扁平化架构

#### 🎯 迁移目标

**从**:
```
src/screens/{PageName}/
├── components/                                     # ❌ 需要移除的中间层
│   ├── {ComponentName}.tsx                        # ❌ 单文件组件
│   └── {AnotherComponent}/                        # ❌ 已重构但位置错误的组件
```

**到**:
```
src/screens/{PageName}/                            # 页面层
├── {ComponentName}/                               # ✅ 伪页面组件 (扁平化)
│   ├── index.tsx                                  # 主组件文件
│   ├── types.ts                                   # 类型定义
│   ├── constants.ts                               # 常量配置
│   ├── use{ComponentName}.ts                      # 状态管理
│   └── [其他架构文件...]
├── {AnotherComponent}/                            # ✅ 另一个伪页面组件
└── {PageName}Screen.tsx                           # 页面主文件
```

#### 🚀 迁移步骤

##### 1️⃣ **单文件组件 → 伪页面组件**

**迁移前**: `src/screens/home/components/UserCard.tsx`

**迁移后**:
```
src/screens/home/UserCard/                         # ✅ 新的伪页面组件位置
├── index.tsx                                      # 从原 UserCard.tsx 重构
├── types.ts                                       # 提取类型定义
├── constants.ts                                   # 提取常量
├── useUserCard.ts                                 # 提取状态管理
├── onUserCardClick.ts                             # 提取事件处理
└── README.md                                      # 组件文档
```

##### 2️⃣ **已重构组件 → 位置调整**

**迁移前**: `src/screens/discover/components/WaterfallCard/`

**迁移后**: `src/screens/discover/WaterfallCard/` (仅调整位置)

##### 3️⃣ **更新导入路径**

**迁移前**:
```typescript
import UserCard from './components/UserCard';
import WaterfallCard from './components/WaterfallCard';
```

**迁移后**:
```typescript
import UserCard from './UserCard';
import WaterfallCard from './WaterfallCard';
```

##### 4️⃣ **移除空的 components/ 文件夹**

所有组件迁移完成后，删除空的 `components/` 文件夹。

#### ✅ 迁移验证清单

- [ ] 所有组件都位于 `src/screens/{PageName}/{ComponentName}/`
- [ ] 不存在 `components/` 中间层级
- [ ] 单文件组件已重构为完整架构结构
- [ ] 导入路径已更新
- [ ] 功能测试通过
- [ ] 每个伪页面组件都有完整的架构文件

### 🎯 伪页面组件架构收益

#### ✅ **扁平化优势**
1. **减少层级嵌套** - 移除不必要的 `components/` 中间层
2. **提升组件地位** - 组件获得更大的架构自主权
3. **便于功能扩展** - 组件可以轻松成长为复杂功能模块
4. **开发效率提升** - 减少文件路径长度，提高开发体验
5. **职责更清晰** - 每个组件都是独立的功能单元

#### 🔄 **重构策略**
1. **保留已重构的组件** - 如 `WaterfallCard/` 已经符合架构标准，仅需调整位置
2. **重构单文件组件** - 将 `.tsx` 单文件重构为文件夹结构
3. **移除中间层级** - 将所有组件提升到页面层级
4. **更新导入路径** - 更新相关的 import 语句

#### 🚀 **最终效果**
每个伪页面组件都成为**"小页面"**，拥有完整的功能和架构权力，支持独立开发、测试和维护！

---

## 📄 文档信息

**版本**: 2.0.0  
**更新日期**: 2024年  
**适用范围**: 所有现代前端框架和编程语言  
**架构标准**: 统一完整结构，无分级简化  
**维护者**: 架构团队

### 🎯 混合架构核心原则总结

#### 🏗️ **架构层面原则**
1. **扁平化组织** - 所有组件直接位于 `src/screens/{PageName}/{ComponentName}/`
2. **移除中间层** - 禁止使用 `components/` 中间层级
3. **混合架构模式** - 根据复杂度选择扁平化或嵌套化架构
4. **统一标准** - 所有伪页面组件都按完整架构实施
5. **不允许简化** - 禁止因组件简单而省略结构
6. **前瞻性设计** - 为未来扩展预留完整架构空间
7. **平等地位** - 伪页面组件与页面主文件处于同一层级
8. **层次映射** - 嵌套结构反映UI的自然功能区域划分

#### 🎯 **架构模式选择原则**
9. **简单组件扁平化** - UI层次≤2层，功能模块≤3个，选择扁平化架构
10. **复杂组件嵌套化** - UI层次≥3层，功能模块≥4个，选择嵌套化架构
11. **功能区域导向** - 有明确功能区域划分时，优先考虑嵌套化架构
12. **内聚性优先** - 子组件高度内聚时，适合嵌套化架构
13. **复用价值权衡** - 跨页面复用价值高时，倾向扁平化架构

#### 💻 **代码实施原则**
14. **YAGNI 原则** - 只实现当前需要的功能，避免过度设计
15. **MVP 原则** - 每个文件只包含核心必需功能，渐进式完善
16. **架构完整 + 实现简洁** - 结构完整但代码简洁
17. **快速迭代** - 优先可用版本，后续根据需求完善

#### 🚀 **执行原则**
18. **强制执行** - Agent 必须严格按标准执行，无选择余地
19. **智能决策** - 根据组件复杂度判断矩阵自动选择架构模式
20. **双重标准** - 架构必须完整，代码必须简洁 (YAGNI + MVP)
