# 04-trade模块 (交易域)

## 模块概述

**模块职责**: 订单管理、支付处理、退款管理、钱包管理

这是应用的**核心交易模块**,负责所有涉及金钱交易的功能,包括订单创建、支付、退款等核心业务流程。

---

## 后端服务 (2个)

### OrderService (订单服务)
- **文档**: [Backend/订单服务接口文档.md](./Backend/订单服务接口文档.md)
- **职责**: 订单创建、订单管理、订单状态流转
- **端口**: 8201
- **API路径**: `/api/order/*`
- **接口数**: 8个
- **对外API**: 6个
- **RPC接口**: 2个

**主要功能**:
- 订单预览与创建
- 订单状态查询
- 订单取消与退款
- 订单列表管理

### PaymentService (支付服务)
- **文档**: [Backend/支付服务接口文档.md](./Backend/支付服务接口文档.md)
- **职责**: 支付处理、密码验证、余额管理、退款处理
- **端口**: 8202
- **API路径**: `/api/payment/*`
- **接口数**: 13个
- **对外API**: 4个
- **RPC接口**: 9个

**主要功能**:
- 订单支付处理
- 支付密码验证
- 余额充值与提现
- 退款管理

**⚠️ 安全要求**:
- 支付密码加密存储
- 支付操作需要二次验证
- 严格的权限控制
- 完整的审计日志

---

## 前端页面

### 已完成 (4个) ✅

1. [13-确认订单页面.md](./Frontend/13-确认订单页面.md)
   - 路由: `/order/confirm`
   - 功能: 订单预览、选择支付方式、确认下单
   - 接口: `GET /api/order/preview`, `POST /api/order/create`

2. [14-支付页面.md](./Frontend/14-支付页面.md)
   - 路由: `/payment/pay`
   - 功能: 支付密码输入、余额支付、第三方支付
   - 接口: `POST /api/order/pay`, `POST /api/order/pay/verify`

3. [15-支付成功页面.md](./Frontend/15-支付成功页面.md)
   - 路由: `/payment/success`
   - 功能: 支付成功提示、订单详情跳转
   - 接口: `GET /api/order/detail` (可选)

4. [16-订单详情页面.md](./Frontend/16-订单详情页面.md)
   - 路由: `/order/detail`
   - 功能: 订单详情展示、订单操作(取消、申请退款)
   - 接口: `GET /api/order/status`, `POST /api/order/cancel`

### 待创建 (3个) ⚠️

5. **17-订单列表页面.md** (待创建)
   - 路由: `/order/list`
   - 功能: 订单列表、筛选(全部/待支付/已完成/已取消)
   - 接口: `GET /api/order/list`

6. **18-钱包页面.md** (待创建)
   - 路由: `/wallet`
   - 功能: 余额展示、充值入口、提现入口、交易记录
   - 接口: `GET /api/payment/balance`, `GET /api/payment/transactions`

7. **19-充值提现页面.md** (待创建)
   - 路由: `/wallet/recharge` 或 `/wallet/withdraw`
   - 功能: 充值/提现操作
   - 接口: `POST /api/payment/recharge`, `POST /api/payment/withdraw`

---

## 核心业务流程

### 订单创建与支付流程

```
用户选择服务/活动
  ↓
13-确认订单页面
  → GET /api/order/preview (订单预览)
  → POST /api/order/create (创建订单)
  ↓
14-支付页面
  → POST /api/order/pay/verify (验证支付密码)
  → POST /api/order/pay (执行支付)
    ├─ 余额支付: PaymentService.deductBalance() [RPC]
    └─ 第三方支付: 调用支付宝/微信API
  ↓
15-支付成功页面
  → 展示支付结果
  ↓
16-订单详情页面
  → GET /api/order/status (查询订单状态)
```

### 订单取消与退款流程

```
16-订单详情页面
  → POST /api/order/cancel (申请取消)
  ↓
OrderService
  → 验证订单状态
  → 调用 PaymentService.refundBalance() [RPC]
  ↓
退款成功
  → 更新订单状态为 "已退款"
  → 发送退款通知
```

---

## 服务依赖关系

### OrderService 依赖

```
OrderService
  → UserService.getUserInfo() [RPC] (获取用户信息)
  → ServiceService.getDetail() [RPC] (获取服务详情)
  → ActivityService.getDetail() [RPC] (获取活动详情)
  → PaymentService.createPayment() [RPC] (创建支付单)
```

### PaymentService 依赖

```
PaymentService
  → UserService.getUserInfo() [RPC] (获取用户信息)
  → (第三方支付网关) Alipay/WeChat Pay SDK
```

### 被依赖的服务

```
OrderService 被调用:
  ← ServiceService.getOrderCount() (获取服务接单数)
  ← ActivityService.getOrderCount() (获取活动订单数)

PaymentService 被调用:
  ← OrderService (订单支付)
  ← ActivityService (活动支付)
  ← (其他模块的支付需求)
```

---

## 数据库设计

**数据库名**: `trade_db`

**主要表结构**:
```sql
-- 订单表
orders
  - order_id (订单ID)
  - user_id (用户ID)
  - order_type (service/activity) (订单类型)
  - target_id (服务ID或活动ID)
  - amount (订单金额)
  - status (待支付/已支付/已取消/已退款)
  - created_at
  - paid_at
  - cancelled_at

-- 支付表
payments
  - payment_id (支付ID)
  - order_id (关联订单)
  - user_id (用户ID)
  - payment_method (balance/alipay/wechat)
  - amount (支付金额)
  - status (pending/success/failed)
  - trade_no (第三方交易号)
  - created_at
  - paid_at

-- 账户表
accounts
  - user_id (用户ID)
  - balance (余额)
  - frozen_balance (冻结金额)
  - total_recharge (累计充值)
  - total_withdraw (累计提现)
  - updated_at

-- 交易流水表
transactions
  - transaction_id (流水ID)
  - user_id (用户ID)
  - type (recharge/withdraw/payment/refund)
  - amount (金额)
  - balance_after (操作后余额)
  - related_order_id (关联订单,可为空)
  - created_at

-- 退款表
refunds
  - refund_id (退款ID)
  - order_id (订单ID)
  - payment_id (支付ID)
  - amount (退款金额)
  - reason (退款原因)
  - status (pending/success/failed)
  - created_at
  - processed_at
```

---

## 技术栈

### 后端
- **框架**: Spring Boot 3.x
- **ORM**: MyBatis-Plus
- **缓存**: Redis (订单状态缓存)
- **消息队列**: RocketMQ (异步处理支付结果)
- **分布式锁**: Redisson (防止重复支付)
- **定时任务**: XXL-Job (订单超时取消)

### 第三方集成
- **支付宝**: Alipay SDK
- **微信支付**: WeChat Pay SDK

### 安全措施
- **支付密码**: BCrypt加密
- **接口签名**: RSA签名验证
- **幂等性**: Token机制防止重复提交
- **审计日志**: 所有支付操作记录

---

## API映射表

| 前端页面 | 主要API | 后端服务 |
|---------|---------|---------|
| 13-确认订单 | GET /api/order/preview | OrderService |
|  | POST /api/order/create | OrderService |
| 14-支付页面 | POST /api/order/pay | PaymentService |
|  | POST /api/order/pay/verify | PaymentService |
| 15-支付成功 | GET /api/order/detail | OrderService |
| 16-订单详情 | GET /api/order/status | OrderService |
|  | POST /api/order/cancel | OrderService |
| 17-订单列表 (待建) | GET /api/order/list | OrderService |
| 18-钱包 (待建) | GET /api/payment/balance | PaymentService |
|  | GET /api/payment/transactions | PaymentService |
| 19-充值提现 (待建) | POST /api/payment/recharge | PaymentService |
|  | POST /api/payment/withdraw | PaymentService |

---

## RPC接口清单

### OrderService提供

```java
// 获取订单数量(供其他服务统计使用)
Integer getOrderCount(Long targetId, String targetType);
```

### PaymentService提供

```java
// 创建支付单
Payment createPayment(CreatePaymentRequest request);

// 扣减余额
Boolean deductBalance(Long userId, BigDecimal amount, String orderId);

// 增加余额
Boolean addBalance(Long userId, BigDecimal amount, String reason);

// 退款
Boolean refundBalance(Long userId, BigDecimal amount, String orderId);

// 查询余额
BigDecimal getBalance(Long userId);

// 冻结余额
Boolean freezeBalance(Long userId, BigDecimal amount);

// 解冻余额
Boolean unfreezeBalance(Long userId, BigDecimal amount);
```

---

## 测试要点

### 功能测试
- [ ] 订单创建流程完整
- [ ] 支付密码验证正确
- [ ] 余额支付成功扣减余额
- [ ] 第三方支付跳转正常
- [ ] 订单取消退款成功

### 安全测试
- [ ] 支付密码加密存储
- [ ] 防止重复支付
- [ ] 防止订单金额篡改
- [ ] 支付接口需要登录验证
- [ ] 敏感接口加签验证

### 性能测试
- [ ] 订单创建响应时间 < 500ms
- [ ] 支付接口响应时间 < 1s
- [ ] 支持500 TPS并发支付

### 边界测试
- [ ] 余额不足时的处理
- [ ] 订单超时自动取消
- [ ] 支付密码错误次数限制
- [ ] 退款金额验证

---

## 监控告警

### 关键指标
- 订单创建成功率
- 支付成功率
- 退款处理时长
- 账户余额异常波动

### 告警规则
- 支付成功率 < 95% → P1告警
- 退款处理超过30分钟 → P2告警
- 账户余额出现负数 → P0告警
- 订单金额异常 (>10000元) → 人工审核

---

## 下一步计划

### Phase 1: 补全前端页面 (优先级P1)
- [ ] 创建 17-订单列表页面.md
- [ ] 创建 18-钱包页面.md
- [ ] 创建 19-充值提现页面.md

### Phase 2: 功能增强
- [ ] 实现订单搜索功能
- [ ] 添加订单评价功能
- [ ] 支持多种支付方式
- [ ] 完善退款审核流程

### Phase 3: 性能优化
- [ ] 订单缓存优化
- [ ] 支付接口性能调优
- [ ] 数据库索引优化

---

**⚠️ 重要提示**:
本模块涉及资金交易,开发时必须严格遵循安全规范,所有代码变更需要经过CodeReview和安全审计。

**模块维护者**: 交易域团队
**最后更新**: 2025-11-14
