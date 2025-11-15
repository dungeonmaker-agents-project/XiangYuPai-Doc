# 🏗️ 前端企业级架构标准

> **适用范围**: React / React Native / Vue / 通用前端项目
> **版本**: v4.0 - 实战精简版
> **更新日期**: 2025-11-13

---

## 📑 目录

1. [核心理念](#核心理念)
2. [三层架构体系](#三层架构体系)
3. [架构决策](#架构决策)
4. [Features 模块化架构](#features-模块化架构)
5. [伪页面组件架构](#伪页面组件架构)
6. [完整结构标准](#完整结构标准)
7. [文件命名规范](#文件命名规范)
8. [实施原则](#实施原则-yagni--mvp)
9. [Agent 执行指令](#agent-执行指令)

---

## 🎯 核心理念

### 架构完整 ≠ 代码复杂

```
架构层面：结构必须完整（前瞻性设计）
代码层面：最小可用实现（YAGNI + MVP）
```

### 四大设计原则

1. **框架无关性** - 思想不依赖特定技术栈
2. **具名化原则** - 文件名直接反映功能职责
3. **单一职责原则** - 每个文件只负责一个具体功能
4. **自包含原则** - 模块包含所有相关代码

---

## 🏛️ 三层架构体系

```
前端项目架构（三层递进）
│
├─ 🏢 项目层 - Features 模块化
│   └─ 组织：src/features/{ModuleName}/
│   └─ 示例：AuthModule, Homepage, Messages
│
├─ 📄 页面层 - 伪页面组件
│   └─ 组织：{ModuleName}/{PageName}/{ComponentName}/
│   └─ 模式：扁平化（简单）/ 嵌套化（复杂）
│
└─ 🧩 模块层 - 完整结构标准
    └─ 组织：index, types, constants, README + 功能文件
    └─ 适用：所有组件、所有页面
```

---

## 🎯 架构决策

### Level 1: 项目级决策
```
问题：如何组织整个项目？
方案：Features 模块化架构
路径：src/features/{ModuleName}/
```

### Level 2: 页面级决策
```
问题：如何组织页面内组件？
方案：伪页面组件架构

判断标准：
├─ UI层次 ≤ 2层，功能 ≤ 3个 → 🟢 扁平化
└─ UI层次 ≥ 3层，功能 ≥ 4个 → 🔵 嵌套化
```

### Level 3: 模块级决策
```
问题：如何组织组件内部？
方案：完整结构标准（100%强制）

核心文件（必需）：
✅ index.[ext]      - 主文件
✅ types.[ext]      - 类型定义
✅ constants.[ext]  - 常量配置
✅ README.md        - 组件文档

功能文件（按需）：
🟡 use*.[ext]       - 状态管理
🟡 on*.[ext]        - 事件处理
🟡 api*.[ext]       - API接口
🟡 process*.[ext]   - 数据处理
🟡 navigate*.[ext]  - 导航处理
```

---

## 🏢 Features 模块化架构

### 标准目录结构

```
src/features/
│
├─ {ModuleName}/                    # 业务功能模块
│   │
│   ├─ api/                         # 模块API
│   │   ├─ {moduleName}Api.ts
│   │   ├─ types.ts                # API类型
│   │   └─ index.ts
│   │
│   ├─ types/                       # 模块类型（集中管理）
│   │   ├─ {domain}.ts             # 领域类型
│   │   ├─ form.ts                 # 表单类型
│   │   └─ index.ts
│   │
│   ├─ stores/                      # 模块状态
│   ├─ hooks/                       # 模块Hooks
│   ├─ utils/                       # 模块工具
│   ├─ config/                      # 模块配置
│   ├─ data/                        # 模块数据
│   │
│   ├─ {PageName}/                  # 页面
│   │   ├─ index.tsx                # 页面主文件
│   │   ├─ types.ts                 # 页面类型
│   │   ├─ constants.ts             # 页面常量
│   │   ├─ README.md                # 页面文档
│   │   ├─ use{PageName}.ts         # 页面状态（可选）
│   │   │
│   │   ├─ {ComponentName}/         # 伪页面组件
│   │   │   ├─ index.tsx
│   │   │   ├─ types.ts
│   │   │   ├─ constants.ts
│   │   │   ├─ README.md
│   │   │   └─ [功能文件...]
│   │   │
│   │   └─ {ComplexComponent}/      # 复杂嵌套组件
│   │       ├─ index.tsx
│   │       ├─ types.ts
│   │       ├─ constants.ts
│   │       ├─ README.md
│   │       ├─ use{ComplexComponent}.ts
│   │       │
│   │       ├─ {SubComponent1}/     # 子组件
│   │       └─ {SubComponent2}/
│   │
│   ├─ SharedComponents/            # 模块共享组件
│   ├─ index.ts                     # 模块统一导出
│   └─ README.md                    # 模块文档
│
└─ {AnotherModule}/
```

### 模块划分原则

| 原则 | 说明 |
|------|------|
| **业务完整性** | 包含完整业务闭环 |
| **职责单一** | 只负责一个业务领域 |
| **高内聚** | 模块内部高度相关 |
| **低耦合** | 模块间依赖最小 |

---

## 🏗️ 伪页面组件架构

### 核心概念

**伪页面组件** = 直接位于页面下的组件，拥有页面级的功能复杂度和架构自主权。

### 四大权力

1. **位置权力** - 直接位于页面下，无 `components/` 中间层
2. **架构权力** - 完整的文件结构自主权
3. **功能权力** - 独立的状态、事件、数据处理
4. **扩展权力** - 可成长为子页面或嵌套组件

### 🟢 扁平化模式（简单组件）

```
{PageName}/
├─ {SimpleComponent}/
│   ├─ index.[ext]                  # 主文件
│   ├─ types.[ext]                  # 类型
│   ├─ constants.[ext]              # 常量
│   ├─ README.md                    # 文档
│   ├─ use{ComponentName}.[ext]     # 状态（按需）
│   ├─ on{ComponentName}[Action].[ext]  # 事件（按需）
│   └─ [其他功能文件...]
```

**适用条件**:
- UI层次 ≤ 2层
- 功能模块 ≤ 3个
- 跨页面复用价值高

**示例**: PhoneInputArea, PasswordInputArea, CodeInputArea

### 🔵 嵌套化模式（复杂组件）

```
{PageName}/
├─ {ComplexComponent}/
│   ├─ index.[ext]                  # 主文件 - 组合子组件
│   ├─ types.[ext]                  # 类型 - 导出所有类型
│   ├─ constants.[ext]              # 常量 - 导出所有常量
│   ├─ README.md                    # 文档 - 包含子组件说明
│   ├─ use{ComplexComponent}.[ext]  # 主状态 - 协调子组件
│   │
│   ├─ {SubComponent1}/             # 功能区域1
│   │   ├─ index.[ext]
│   │   ├─ types.[ext]              # 可选
│   │   ├─ constants.[ext]          # 可选
│   │   ├─ README.md                # 可选
│   │   └─ [功能文件...]
│   │
│   └─ {SubComponent2}/             # 功能区域2
│       └─ [完整结构...]
```

**适用条件**:
- UI层次 ≥ 3层
- 功能模块 ≥ 4个
- 有明确功能区域划分

**示例**: ForgotPasswordPage（4步骤流程）, LoginMainPage（9个输入区域）

### 决策流程

```
组件架构选择：

1. UI层次 ≤ 2层 且 功能 ≤ 3个？
   └─ 是 → 🟢 扁平化模式

2. 有明确功能区域划分 且 子组件高度内聚？
   └─ 是 → 🔵 嵌套化模式

3. 跨页面复用价值高？
   └─ 是 → 🟢 扁平化模式
   └─ 否 → 🔵 嵌套化模式
```

---

## 🎯 完整结构标准

### 核心文件层（100%必需）

```
{ComponentName}/
├─ index.[ext]          ✅ 主组件文件
├─ types.[ext]          ✅ 类型定义
├─ constants.[ext]      ✅ 常量定义
└─ README.md            ✅ 组件文档
```

**绝对强制规则**:
- 所有组件、所有页面都必须100%包含这4个文件
- 不允许任何例外、不允许简化
- 即使文件内容很少也必须创建

### 功能文件层（按需必需）

| 文件类型 | 创建条件 | 命名规范 |
|---------|---------|----------|
| **状态管理** | 有状态时必须创建 | `use{Name}.[ext]` |
| **事件处理** | 有交互时必须创建 | `on{Name}[Action].[ext]` |
| **API接口** | 有数据交互时必须创建 | `api{Name}[Action].[ext]` |
| **数据处理** | 有数据处理时必须创建 | `process{Name}[Data].[ext]` |
| **导航处理** | 有跳转时必须创建 | `navigateTo{Target}.[ext]` |

**按需必需 = 有相关功能就必须创建对应文件**

### 实战示例：AuthModule 完整结构

```
AuthModule/
├─ api/
│   ├─ authApi.ts
│   ├─ types.ts                     # API类型集中
│   └─ index.ts
│
├─ types/                           # 模块类型集中管理
│   ├─ auth.ts                      # 认证相关类型
│   ├─ user.ts                      # 用户相关类型
│   ├─ form.ts                      # 表单相关类型
│   └─ index.ts
│
├─ stores/
│   ├─ authStore.ts
│   └─ index.ts
│
├─ utils/
│   ├─ credentialStorage.ts
│   ├─ validation.ts                # 验证工具集
│   └─ index.ts
│
├─ hooks/
│   ├─ useAuthInitialization.ts
│   ├─ useRouteGuard.ts
│   └─ index.ts
│
├─ config/
│   ├─ testAccounts.ts
│   ├─ routeWhitelist.ts
│   └─ index.ts
│
├─ data/
│   ├─ countries.ts
│   └─ index.ts
│
├─ LoginMainPage/                   # 登录页（9个子组件扁平化）
│   ├─ index.tsx                    # ✅
│   ├─ types.ts                     # ✅
│   ├─ constants.ts                 # ✅
│   ├─ README.md                    # ✅
│   ├─ useLoginMainPage.ts          # 主状态管理
│   │
│   ├─ TopWelcomeArea/              # 欢迎区域
│   │   ├─ index.tsx                # ✅
│   │   ├─ types.ts                 # ✅
│   │   ├─ constants.ts             # ✅
│   │   └─ README.md                # ✅
│   │
│   ├─ PhoneInputArea/              # 手机输入
│   ├─ PasswordInputArea/           # 密码输入
│   ├─ CodeInputArea/               # 验证码输入
│   ├─ AuthInputArea/               # 认证输入聚合
│   ├─ ActionButtonArea/            # 登录按钮
│   ├─ AuxiliaryArea/               # 辅助链接
│   ├─ AgreementArea/               # 用户协议
│   └─ RegionSelectModal/           # 区号选择
│       └─ [每个都有完整4文件结构]
│
├─ ForgotPasswordPage/              # 忘记密码（4步骤嵌套化）
│   ├─ index.tsx                    # ✅ 主文件
│   ├─ types.ts                     # ✅ 定义 ResetStep, FormData
│   ├─ constants.ts                 # ✅ COLORS, CONFIG, STEPS, TEXT
│   ├─ README.md                    # ✅ 文档
│   ├─ useForgotPasswordFlow.ts     # 多步骤流程状态管理
│   │
│   ├─ StepIndicator/               # 步骤指示器
│   │   ├─ index.tsx                # ✅
│   │   └─ README.md                # ✅
│   │
│   └─ Step4Success/                # 成功步骤
│       ├─ index.tsx                # ✅
│       └─ README.md                # ✅
│
├─ SharedComponents/                # 模块共享组件
│   └─ Layout/
│       └─ AuthSafeArea/
│           ├─ index.tsx            # ✅
│           ├─ types.ts             # ✅
│           ├─ constants.ts         # ✅
│           └─ README.md            # ✅
│
├─ index.ts                         # 模块统一导出
└─ README.md                        # 模块文档

总计文件数：60+
完整结构覆盖率：100%
```

---

## 📋 文件命名规范

### 核心文件（固定命名）

| 文件 | 命名 | 职责 |
|------|------|------|
| 主文件 | `index.[ext]` | 组件UI实现 |
| 类型 | `types.[ext]` | 类型定义 |
| 常量 | `constants.[ext]` | 常量配置 |
| 文档 | `README.md` | 使用说明 |

### 功能文件（语义命名）

| 功能类型 | 命名格式 | 示例 |
|---------|---------|------|
| **状态管理** | `use{Name}.[ext]` | `useLoginMainPage.ts` |
|  | `use{Name}{Feature}.[ext]` | `useForgotPasswordFlow.ts` |
| **事件处理** | `on{Name}{Action}.[ext]` | `onPhoneInputChange.ts` |
| **导航处理** | `navigateTo{Target}.[ext]` | `navigateToProfile.ts` |
| **API接口** | `api{Name}{Action}.[ext]` | `apiUserLogin.ts` |
| **数据处理** | `process{Name}{Data}.[ext]` | `processUserData.ts` |
| **数据转换** | `transform{Name}{Format}.[ext]` | `transformUserFormat.ts` |
| **数据验证** | `validate{Name}{Input}.[ext]` | `validatePhoneNumber.ts` |

### 命名核心原则

```
✅ 使用具名化 - 文件名直接反映功能
✅ 使用语义化 - 名称清晰表达意图
✅ 使用一致性 - 遵循统一规范

❌ 避免通用名 - 不要用 utils, helpers, common
❌ 避免缩写 - 不要用 usr, pwd, btn
❌ 避免模糊名 - 不要用 data, info, item
```

---

## 💡 实施原则（YAGNI + MVP）

### 核心理念

```
架构完整 ≠ 代码复杂

架构层面：结构必须完整（前瞻性设计）
├─ 所有必需文件 100% 创建
├─ 所有功能文件按需创建
└─ 完整的目录层次结构

代码层面：最小可用实现（YAGNI + MVP）
├─ 只实现当前需要的功能
├─ 避免过度设计和预先优化
└─ 渐进式完善
```

### YAGNI 原则（You Aren't Gonna Need It）

- **只实现当前需要的** - 不预先实现可能用到的功能
- **避免过度设计** - 不添加当前用不到的复杂逻辑
- **简单优先** - 优先选择最简单的实现方式

### MVP 原则（Minimum Viable Product）

- **最小可用实现** - 每个文件只包含核心必需功能
- **渐进式完善** - 后续根据实际需求逐步完善
- **快速迭代** - 优先实现可用版本，再优化完善

### 实施示例

```typescript
// ✅ 推荐：YAGNI + MVP 实施

// types.ts - 只定义当前需要的类型
export interface UserCardProps {
  id: string;
  name: string;
  avatar?: string;  // 可选属性，按需添加
}

// constants.ts - 只定义当前使用的常量
export const USER_CARD_HEIGHT = 120;
export const DEFAULT_AVATAR = '/images/default-avatar.png';

// useUserCard.ts - 最小可用状态管理
export const useUserCard = (props: UserCardProps) => {
  const [isLoading, setIsLoading] = useState(false);
  // 只实现当前需要的状态
  return { isLoading, setIsLoading };
};

// ❌ 避免：过度设计
// 不要预先实现：
// - 复杂缓存机制
// - 复杂计算逻辑
// - 未使用的高级功能
// - 过度抽象的架构
```

### 渐进式完善策略

```
阶段1：创建完整文件结构
✅ 创建所有必需文件（index, types, constants, README）
✅ 创建所有功能文件（根据实际功能需求）
✅ 建立完整的目录层次

阶段2：实施 YAGNI + MVP 代码
✅ 每个文件只实现当前需要的功能
✅ 避免过度设计和预先优化
✅ 保持代码简洁可读

阶段3：根据需求渐进完善
✅ 功能扩展时补充对应内容
✅ 重构时保持架构结构不变
✅ 持续优化代码质量
```

---

## 🤖 Agent 执行指令

### 强制执行规则

#### 1. 完整结构 100% 强制

```
所有组件都必须按完整结构组织：
✅ index.[ext]      - 100% 必需
✅ types.[ext]      - 100% 必需
✅ constants.[ext]  - 100% 必需
✅ README.md        - 100% 必需

功能文件按需必需：
🟡 有状态 → 必须创建 use*.[ext]
🟡 有交互 → 必须创建 on*.[ext]
🟡 有API → 必须创建 api*.[ext]
🟡 有数据处理 → 必须创建 process*.[ext]
🟡 有导航 → 必须创建 navigate*.[ext]

不存在分级选择，不允许简化！
```

#### 2. 架构模式自动选择

```
扁平化条件：
✅ UI层次 ≤ 2层
✅ 功能模块 ≤ 3个
✅ 跨页面复用价值高

嵌套化条件：
✅ UI层次 ≥ 3层
✅ 功能模块 ≥ 4个
✅ 有明确功能区域划分
✅ 子组件高度内聚
```

#### 3. 代码实施原则

```
架构层面：
✅ 结构必须完整（100%实施完整结构标准）
✅ 文件必须齐全（核心4文件 + 功能文件）
✅ 层次必须清晰（Features → Page → Component）

代码层面：
✅ YAGNI原则（只实现当前需要的）
✅ MVP原则（最小可用实现）
✅ 渐进式完善（后续逐步优化）
```

#### 4. 禁止行为

```
❌ 缺少核心4文件（index/types/constants/README）
❌ 省略功能文件（有功能但无对应文件）
❌ 创建 components/ 中间层（Features下直接是页面/组件）
❌ 职责混合（多个功能写在一个文件）
❌ 类型定义缺失（未定义TypeScript类型）
❌ 常量硬编码（未提取到constants）
❌ 文件命名不规范（不符合命名规范）
```

### 执行步骤

#### 阶段1：分析规划

```
1. 确定架构层级（Project/Page/Module）
2. 分析组件复杂度（扁平化 vs 嵌套化）
3. 识别所有功能模块
4. 列出完整文件清单
5. 规划完整架构结构
```

#### 阶段2：创建结构

```
1. 创建根目录
2. 创建核心4文件（index, types, constants, README）
3. 根据功能需求创建功能文件
4. 嵌套组件创建子组件目录
5. 确保结构100%完整
```

#### 阶段3：实施代码（YAGNI + MVP）

```
1. 拆分代码到对应文件
2. 提取类型定义（仅当前需要）
3. 提取常量（仅当前使用）
4. 实施状态管理（最小可用）
5. 实施事件处理（核心事件）
6. 组装主组件（简洁清晰）
```

#### 阶段4：验证文档

```
1. 检查文件命名规范
2. 检查职责单一性
3. 检查类型完整性
4. 检查导入导出
5. 编写完整README文档
6. 验证结构100%合规
```

### 实战案例参考

**成功案例**：AuthModule 重构
- **完整结构覆盖率**：100%
- **文件总数**：60+ 文件
- **文档覆盖率**：100%
- **架构合规性**：100%

**关键经验**：
1. ✅ 先创建完整结构，再填充代码
2. ✅ 核心4文件必须100%创建，无例外
3. ✅ 功能文件按需创建，有功能就创建对应文件
4. ✅ 代码实施遵循YAGNI+MVP，避免过度设计
5. ✅ 集中管理类型（types/文件夹）便于复用
6. ✅ 文档必须完整，README.md不可省略

---

## ✅ 验证清单

### 结构验证

```
核心文件验证（100%必需）:
□ index.[ext] - 主组件文件存在且功能完整
□ types.[ext] - 类型定义文件存在且导出完整
□ constants.[ext] - 常量定义文件存在且提取完整
□ README.md - 组件文档存在且说明完整

功能文件验证（按需必需）:
□ 有状态 → use*.[ext] 已创建
□ 有交互 → on*.[ext] 已创建
□ 有跳转 → navigate*.[ext] 已创建
□ 有API → api*.[ext] 已创建
□ 有数据处理 → process*.[ext] 已创建

架构验证:
□ 组件位置正确（无components/中间层）
□ 架构模式选择正确（扁平化/嵌套化）
□ 文件命名符合规范
□ 职责分离清晰
```

### 代码验证

```
TypeScript验证:
□ 编译无错误
□ 类型覆盖率 >95%
□ 避免使用any

实施原则验证:
□ 遵循YAGNI原则（只实现当前需要的）
□ 遵循MVP原则（最小可用实现）
□ 代码简洁可读
□ 无过度设计
```

---

## 🎯 核心原则总结

### 架构原则（10条）

```
1. Features模块化 - 按业务功能划分模块
2. 伪页面组件 - 组件直接位于页面下
3. 完整结构标准 - 100%实施完整结构
4. 核心4文件必需 - index/types/constants/README
5. 功能文件按需 - 有功能就创建对应文件
6. 扁平化优先 - 简单组件用扁平化
7. 嵌套化适配 - 复杂组件用嵌套化
8. 具名化命名 - 文件名反映功能
9. 单一职责 - 每个文件一个功能
10. 自包含原则 - 模块包含所有相关代码
```

### 实施原则（10条）

```
11. 架构完整 - 结构必须100%完整
12. YAGNI原则 - 只实现当前需要的
13. MVP原则 - 最小可用实现
14. 渐进完善 - 后续逐步优化
15. 类型优先 - TypeScript严格模式
16. 常量提取 - 避免硬编码
17. 职责分离 - 状态、事件、数据分离
18. 文档完整 - 所有组件都有README
19. 代码简洁 - 避免过度设计
20. 持续优化 - 重构时保持架构不变
```

---

## 📊 关键指标

| 指标 | 目标 | 说明 |
|------|------|------|
| **架构一致性** | 100% | 所有模块遵循统一架构 |
| **完整结构覆盖率** | 100% | 所有组件实施完整结构 |
| **类型覆盖率** | >95% | TypeScript类型覆盖 |
| **文档覆盖率** | 100% | 所有组件都有README |
| **命名规范性** | 100% | 文件命名符合规范 |

---

## 📚 适用场景

### 使用 Features 架构
- ✅ 大型应用（多个业务模块）
- ✅ 需要模块化管理
- ✅ 多人团队协作
- ✅ 独立开发和部署

### 使用伪页面组件架构
- ✅ 所有页面级组件
- ✅ 所有功能组件
- ✅ 需要清晰层级
- ✅ 独立测试维护

### 使用完整结构标准
- ✅ 所有组件（100%强制）
- ✅ 所有页面（100%强制）
- ✅ 所有模块（100%强制）
- ✅ 无例外情况

---

## 📄 文档信息

**版本**: v4.0 - 实战精简版
**更新日期**: 2025-11-13
**基于实战**: AuthModule 完整重构经验
**适用范围**: React / React Native / Vue / 通用前端项目
**维护者**: 前端架构团队

---

**架构清晰，结构完整，代码简洁，质量第一。** 🚀

**实战验证，精简聚焦，可落地执行！** ✨
