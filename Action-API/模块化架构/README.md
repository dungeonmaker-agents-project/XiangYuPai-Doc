# 模块化架构文档

## 📚 架构概述

本文档库采用**模块化架构**,将整个应用划分为 **6大业务模块**,包含 **11个微服务**。

### 架构原则

- **前后端分离**: Frontend文档按页面组织,Backend文档按微服务组织
- **模块自治**: 每个模块有独立的前端页面和后端服务
- **清晰边界**: 服务间通过标准API和RPC调用通信
- **数据隔离**: 每个模块使用独立数据库

---

## 🗂️ 模块结构

```
模块化架构/
├── 00-架构文档/              [架构设计文档]
├── 01-auth模块/              [认证授权模块]
├── 02-user模块/              [用户域模块]
├── 03-content模块/           [内容域模块] ⭐ 核心
├── 04-trade模块/             [交易域模块] ⭐ 核心
├── 05-chat模块/              [聊天消息模块]
└── 06-common模块/            [基础设施模块]
```

---

## 📋 模块清单

### 00-架构文档

**职责**: 整体架构设计、规范、分析报告

**文档列表**:
- [模块架构总览.md](./00-架构文档/模块架构总览.md) - 6模块架构方案
- [微服务架构分析与建议.md](./00-架构文档/微服务架构分析与建议.md) - 微服务拆分方案
- [文档重组完成总结.md](./00-架构文档/文档重组完成总结.md) - 文档重组记录
- [接口文档编写模板与规范.md](./00-架构文档/接口文档编写模板与规范.md) - 文档规范

---

### 01-auth模块

**模块职责**: 认证授权、登录注册、权限管理

**后端服务**: 1个
- AuthService (认证服务) - *待创建*

**前端页面**: 4个 *待创建*
- 01-登录页面.md
- 02-注册页面.md
- 03-找回密码页面.md
- 04-设置支付密码页面.md

**数据库**: `auth_db`

**API路径**: `/api/auth/*`

**服务依赖**:
- 被所有服务依赖(Token验证)

---

### 02-user模块

**模块职责**: 用户资料、关注关系、用户主页

**后端服务**: 1个
- [UserService](./02-user模块/Backend/用户服务接口文档.md) (用户服务) ✅

**前端页面**: 5个 *待创建*
- 01-个人主页.md
- 02-编辑资料页面.md
- 03-粉丝列表页面.md
- 04-关注列表页面.md
- 05-实名认证页面.md

**数据库**: `user_db`

**API路径**: `/api/user/*`

**RPC接口**:
- `getUserInfo()` - 获取用户信息
- `follow()` - 关注/取关用户
- `getUserRelation()` - 获取用户关系

**服务依赖**:
- 被所有业务服务调用(获取用户信息)

---

### 03-content模块 ⭐

**模块职责**: 内容发现、搜索、活动组局、技能服务

**后端服务**: 4个
- [HomeService](./03-content模块/Backend/首页服务接口文档.md) (首页服务) ✅
- [SearchService](./03-content模块/Backend/搜索服务接口文档.md) (搜索服务) ✅
- [ActivityService](./03-content模块/Backend/活动服务接口文档.md) (活动服务) ✅
- [ServiceService](./03-content模块/Backend/技能服务接口文档.md) (技能服务) ✅

**前端页面**: 10个 ✅
- [01-首页Feed流页面.md](./03-content模块/Frontend/01-首页Feed流页面.md)
- [02-筛选页面.md](./03-content模块/Frontend/02-筛选页面.md)
- [05-限时专享页面.md](./03-content模块/Frontend/05-限时专享页面.md)
- [06-搜索页面.md](./03-content模块/Frontend/06-搜索页面.md)
- [07-搜索结果页面.md](./03-content模块/Frontend/07-搜索结果页面.md)
- [08-组局中心列表页面.md](./03-content模块/Frontend/08-组局中心列表页面.md)
- [09-组局详情页面.md](./03-content模块/Frontend/09-组局详情页面.md)
- [10-发布组局页面.md](./03-content模块/Frontend/10-发布组局页面.md)
- [11-服务列表页面.md](./03-content模块/Frontend/11-服务列表页面.md)
- [12-服务详情页面.md](./03-content模块/Frontend/12-服务详情页面.md)

**数据库**: `content_db`

**API路径**:
- `/api/home/*` - 首页Feed
- `/api/search/*` - 搜索功能
- `/api/activity/*` - 组局活动
- `/api/service/*` - 技能服务

**服务依赖**:
- → UserService (获取用户信息)
- → LocationService (计算距离)
- → CommonService (图片上传)

---

### 04-trade模块 ⭐

**模块职责**: 订单管理、支付处理、退款管理

**后端服务**: 2个
- [OrderService](./04-trade模块/Backend/订单服务接口文档.md) (订单服务) ✅
- [PaymentService](./04-trade模块/Backend/支付服务接口文档.md) (支付服务) ✅

**前端页面**: 4个 ✅ + 3个待创建
- [13-确认订单页面.md](./04-trade模块/Frontend/13-确认订单页面.md) ✅
- [14-支付页面.md](./04-trade模块/Frontend/14-支付页面.md) ✅
- [15-支付成功页面.md](./04-trade模块/Frontend/15-支付成功页面.md) ✅
- [16-订单详情页面.md](./04-trade模块/Frontend/16-订单详情页面.md) ✅
- 17-订单列表页面.md *待创建*
- 18-钱包页面.md *待创建*
- 19-充值提现页面.md *待创建*

**数据库**: `trade_db`

**API路径**:
- `/api/order/*` - 订单管理
- `/api/payment/*` - 支付处理

**RPC接口**:
- `createPayment()` - 创建支付单
- `deductBalance()` - 扣减余额
- `refundBalance()` - 退款
- `getOrderCount()` - 获取订单数

**服务依赖**:
- → UserService (获取用户信息)
- → ServiceService/ActivityService (获取商品信息)

---

### 05-chat模块

**模块职责**: 实时聊天、消息通知、推送

**后端服务**: 1个
- MessageService (消息服务) - *待创建*

**前端页面**: 3个 *待创建*
- 01-消息列表页面.md
- 02-聊天页面.md
- 03-通知中心页面.md

**数据库**: `chat_db`

**API路径**:
- `/api/message/*` - 消息管理
- `/api/chat/*` - 聊天功能

**技术栈**:
- WebSocket (实时通讯)
- Redis (消息队列)

**服务依赖**:
- → UserService (获取用户信息)

---

### 06-common模块

**模块职责**: 文件上传、位置服务、配置管理

**后端服务**: 2个
- [CommonService](./06-common模块/Backend/通用服务接口文档.md) (通用服务) ✅
- [LocationService](./06-common模块/Backend/位置服务接口文档.md) (位置服务) ✅

**前端页面**: 2个 ✅
- [03-区域选择页面.md](./06-common模块/Frontend/03-区域选择页面.md)
- [04-城市定位页面.md](./06-common模块/Frontend/04-城市定位页面.md)

**数据库**: `infra_db` + OSS

**API路径**:
- `/api/common/*` - 通用功能
- `/api/location/*` - 位置服务

**RPC接口**:
- `uploadImage()` - 图片上传
- `getDistance()` - 计算距离
- `getCityInfo()` - 获取城市信息

**服务依赖**:
- 被所有服务调用(基础设施)

---

## 🔗 服务依赖关系

### 被依赖服务 (基础设施)

```
CommonService (通用服务)
  ← ActivityService (上传活动图片)
  ← UserService (上传头像)
  ← ServiceService (上传服务图片)

LocationService (位置服务)
  ← HomeService (计算距离)
  ← SearchService (位置信息)
  ← ActivityService (活动距离)
  ← ServiceService (服务距离)

UserService (用户服务)
  ← 所有业务服务 (获取用户信息)
```

### 业务服务调用链

```
前端页面 → API Gateway → 业务服务 → RPC调用基础服务

示例: 首页Feed流
01-首页Feed流页面
  → HomeService.getFeed()
    → UserService.getUserInfo() [RPC]
    → LocationService.getDistance() [RPC]
  → 返回聚合数据
```

---

## 📊 统计信息

| 模块 | 前端页面 | 后端服务 | 总API数 | 状态 |
|------|---------|---------|---------|------|
| auth | 4 (待建) | 1 (待建) | ~15 | ⚠️ 待创建 |
| user | 5 (待建) | 1 ✅ | 8 | ⚠️ 前端待建 |
| content | 10 ✅ | 4 ✅ | 28 | ✅ 完成 |
| trade | 7 (4✅+3待建) | 2 ✅ | 21 | ⚠️ 部分完成 |
| chat | 3 (待建) | 1 (待建) | ~10 | ⚠️ 待创建 |
| common | 2 ✅ | 2 ✅ | 15 | ✅ 完成 |
| **总计** | **31个页面** | **11个服务** | **~97 APIs** | **45%完成** |

---

## 🚀 开发指南

### 前端开发者

1. **找到对应模块**: 根据功能找到对应的模块文件夹
2. **阅读页面文档**: 进入 `Frontend/` 查看页面文档
3. **实现页面**: 根据文档的UI结构、接口列表、数据流实现
4. **对接后端**: 根据文档中的"使用的后端服务"章节对接API

**示例**: 实现首页Feed流
```
1. 打开: 03-content模块/Frontend/01-首页Feed流页面.md
2. 查看: 页面UI结构、接口列表(GET /api/home/feed)
3. 实现: 页面组件、状态管理、接口调用
4. 测试: 根据"测试要点"章节验证
```

### 后端开发者

1. **找到对应模块**: 根据业务域找到对应的模块文件夹
2. **阅读服务文档**: 进入 `Backend/` 查看微服务文档
3. **实现服务**: 根据文档的API列表、数据模型、业务逻辑实现
4. **提供RPC**: 如果标记为RPC服务,提供内部接口

**示例**: 实现订单服务
```
1. 打开: 04-trade模块/Backend/订单服务接口文档.md
2. 查看: 接口列表(8个API)、数据模型、RPC接口
3. 实现: Controller、Service、Mapper层
4. 测试: 根据接口定义编写单元测试
```

### 架构师/Tech Lead

1. **查看架构文档**: 进入 `00-架构文档/` 了解整体架构
2. **规划服务**: 根据微服务架构分析决定服务拆分
3. **定义契约**: 确保API契约清晰,前后端协作顺畅
4. **监控依赖**: 使用服务依赖关系图避免循环依赖

---

## 📝 文档使用规范

### 前端页面文档结构

```markdown
# XX-页面名称

## 一、页面概述
- 路由路径
- 页面功能
- 用户角色

## 三、接口列表
### 3.1 页面加载时调用
### 3.2 用户操作触发

## 四、数据流
## 五、状态管理
## 六、路由参数
## 八、测试要点
## 九、使用的后端服务
```

### 后端服务文档结构

```markdown
# XX服务接口文档 (ServiceName)

## 一、服务概述
- 服务职责
- 技术栈
- 端口
- 数据库

## 二、接口列表
### 2.1 对外API
### 2.2 内部RPC

## 三、数据模型
## 四、业务逻辑
## 五、缓存策略
## 六、监控告警
```

---

## ⚠️ 重要说明

### API路径保持不变

为避免破坏性变更,所有API路径保持原有规范:

```
/api/home/*      → HomeService (content模块)
/api/service/*   → ServiceService (content模块)
/api/order/*     → OrderService (trade模块)
/api/payment/*   → PaymentService (trade模块)
/api/user/*      → UserService (user模块)
/api/location/*  → LocationService (common模块)
/api/common/*    → CommonService (common模块)
```

**API Gateway** 负责路由到对应的微服务。

### 数据库设计

每个模块使用独立数据库,遵循微服务原则:

```
auth_db      - 认证凭证
user_db      - 用户资料
content_db   - 内容数据
trade_db     - 订单支付
chat_db      - 聊天消息
infra_db     - 基础数据(位置、配置)
```

---

## 📅 下一步计划

### Phase 1: 补全核心模块 (优先级P0)

- [ ] 创建 auth模块 文档 (4前端 + 1后端)
- [ ] 创建 chat模块 文档 (3前端 + 1后端)
- [ ] 补全 user模块 前端文档 (5个页面)
- [ ] 补全 trade模块 前端文档 (3个页面)

### Phase 2: 验证和测试

- [ ] 验证所有API映射正确
- [ ] 验证前后端文档一致性
- [ ] 创建接口测试用例

### Phase 3: 开发实施

- [ ] 前端按模块组建团队开发
- [ ] 后端按服务划分开发任务
- [ ] 配置API Gateway路由

---

## 📞 联系方式

如有文档问题或建议,请联系架构团队。

---

**文档版本**: v1.0
**创建日期**: 2025-11-14
**最后更新**: 2025-11-14
**维护团队**: 架构组
