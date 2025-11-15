# 01-auth模块 (认证授权)

## 模块概述

**模块职责**: 用户认证、登录注册、权限管理、Token管理

这是应用的**安全基础模块**,负责所有与用户身份认证和授权相关的功能。

✅ **当前状态**: 模块已完成，文档齐全

---

## 后端服务 (1个)

### AuthService (认证服务) ✅
- **文档**: [Backend/认证服务接口文档.md](./Backend/认证服务接口文档.md)
- **职责**: 登录认证、Token管理、支付密码管理、验证码服务
- **端口**: 8001
- **API路径**: `/api/auth/*`
- **接口数**: 11个对外API + 2个RPC接口

**核心功能**:
- 密码登录 + 验证码登录
- 验证码登录自动注册新用户
- 忘记密码（3步流程）
- 设置/修改支付密码
- Token生成与刷新(JWT)
- 登出（Token黑名单）
- 手机号注册检查

---

## 前端页面 (4个) ✅

1. **[01-密码登录页面.md](./Frontend/01-密码登录页面.md)** ✅
   - 路由: `/auth/login/password`
   - 功能: 手机号+密码登录
   - 主要接口:
     - `POST /api/auth/login/password` - 密码登录

2. **[02-验证码登录页面.md](./Frontend/02-验证码登录页面.md)** ✅
   - 路由: `/auth/login/sms`
   - 功能: 手机号+验证码登录，未注册用户自动注册
   - 主要接口:
     - `POST /api/auth/sms/send` - 发送验证码
     - `POST /api/auth/login/sms` - 验证码登录(含自动注册)

3. **[03-忘记密码页面.md](./Frontend/03-忘记密码页面.md)** ✅
   - 路由: `/auth/forgot-password`
   - 功能: 忘记密码3步流程（手机号→验证码→新密码）
   - 主要接口:
     - `POST /api/auth/sms/send` - 发送验证码(purpose: RESET_PASSWORD)
     - `POST /api/auth/password/reset/verify` - 验证验证码
     - `POST /api/auth/password/reset/confirm` - 设置新密码

4. **[04-设置支付密码页面.md](./Frontend/04-设置支付密码页面.md)** ✅
   - 路由: `/auth/payment-password/set` 或 `/auth/payment-password/update`
   - 功能: 设置/修改6位数字支付密码
   - 主要接口:
     - `POST /api/auth/payment-password/set` - 设置支付密码
     - `POST /api/auth/payment-password/update` - 修改支付密码
     - `POST /api/auth/payment-password/verify` - 验证支付密码

---

## 核心业务流程

### 密码登录流程

```
01-密码登录页面
  1. 输入手机号+密码
  2. 点击"登陆"按钮
  ↓
POST /api/auth/login/password
  ↓
AuthService
  1. 验证手机号和密码(BCrypt)
  2. 检查账号状态
  3. 生成Access Token (有效期2小时)
  4. 生成Refresh Token (有效期7天)
  5. 记录登录日志
  ↓
客户端
  1. 保存Token到本地
  2. 跳转到主页
```

### 验证码登录/注册流程

```
02-验证码登录页面
  1. 输入手机号
  2. 点击"获取验证码" → POST /api/auth/sms/send
  3. 输入6位验证码（自动提交）
  ↓
POST /api/auth/login/sms
  ↓
AuthService
  1. 验证验证码
  2. 检查手机号是否已注册
  3. 未注册: 自动创建账号 (调用UserService.createUser)
  4. 生成Token
  5. 返回Token + isNewUser标记
  ↓
客户端
  1. 保存Token
  2. isNewUser = true: 跳转到完善资料页面
  3. isNewUser = false: 跳转到主页
```

### 忘记密码流程

```
03-忘记密码页面 (3步流程)

步骤1: 输入手机号
  ↓ POST /api/auth/sms/send (purpose: RESET_PASSWORD)

步骤2: 验证码输入
  ↓ POST /api/auth/password/reset/verify

步骤3: 设置新密码
  ↓ POST /api/auth/password/reset/confirm
  ↓
密码重置成功 → 返回登录页
```

### 支付密码设置/修改流程

```
04-设置支付密码页面

设置模式(新用户):
  1. 输入6位数字密码
  2. 确认密码
  ↓ POST /api/auth/payment-password/set
  ↓ 设置成功

修改模式(已有密码):
  1. 输入原密码
  2. 输入新密码
  3. 确认新密码
  ↓ POST /api/auth/payment-password/update
  ↓ 修改成功
```

### Token刷新流程

```
客户端
  1. 检测Token即将过期
  2. POST /api/auth/token/refresh (携带Refresh Token)
  ↓
AuthService
  1. 验证Refresh Token有效性
  2. 生成新的Access Token
  3. 返回新Token
```

---

## 服务依赖关系

### AuthService 依赖

```
AuthService
  → UserService.createUser() [RPC] (注册时创建用户)
  → UserService.getUserByPhone() [RPC] (登录验证)
  → SMS服务 (发送验证码)
  → 第三方OAuth (微信/QQ登录)
```

### 被依赖的服务

```
AuthService 被调用:
  ← 所有服务 (Token验证,通过API Gateway拦截器)
```

**Token验证**: 通过API Gateway统一拦截,调用AuthService验证Token有效性。

---

## 数据库设计

**数据库名**: `auth_db`

**主要表结构**:
```sql
-- 用户凭证表
user_credentials
  - user_id (用户ID,主键,与user_db的users表关联)
  - phone (手机号,唯一)
  - password_hash (密码哈希值,BCrypt)
  - payment_password_hash (支付密码哈希值)
  - salt (密码盐值)
  - created_at
  - updated_at

-- Token表
tokens
  - token_id (TokenID)
  - user_id (用户ID)
  - access_token (访问Token)
  - refresh_token (刷新Token)
  - access_token_expires_at (访问Token过期时间)
  - refresh_token_expires_at (刷新Token过期时间)
  - device_id (设备ID)
  - device_type (ios/android/web)
  - ip_address (IP地址)
  - created_at
  - revoked_at (撤销时间,登出时设置)

-- 验证码表
sms_codes
  - phone (手机号)
  - code (验证码,6位数字)
  - code_type (register/login/reset_password)
  - expires_at (过期时间,5分钟)
  - used (是否已使用)
  - created_at

-- 第三方登录绑定表
oauth_bindings
  - binding_id (绑定ID)
  - user_id (用户ID)
  - oauth_type (wechat/qq/alipay)
  - oauth_id (第三方用户ID)
  - oauth_token (第三方Token)
  - bound_at (绑定时间)

-- 登录日志表
login_logs
  - log_id (日志ID)
  - user_id (用户ID)
  - login_type (password/sms/wechat/qq)
  - ip_address (IP地址)
  - device_type (设备类型)
  - device_info (设备信息)
  - location (登录地点)
  - status (success/failed)
  - login_time
```

---

## 技术栈

### 后端
- **框架**: Spring Boot 3.x + Spring Security
- **Token**: JWT (JSON Web Token)
- **密码加密**: BCrypt
- **SMS**: 阿里云短信服务
- **OAuth**: 微信开放平台SDK、QQ互联SDK
- **缓存**: Redis (验证码、Token黑名单)

### 安全措施
- **密码加密**: BCrypt (强度12)
- **Token签名**: HMAC-SHA256
- **验证码**: 5分钟有效期,1小时内最多发送5次
- **登录限制**: 密码错误5次锁定30分钟
- **Token黑名单**: 登出后Token加入黑名单
- **HTTPS**: 所有认证接口强制HTTPS

---

## API路径规划

### 对外API (11个)

| API路径 | 方法 | 功能 | 状态 |
|---------|------|------|------|
| /api/auth/login/password | POST | 密码登录 | ✅ |
| /api/auth/login/sms | POST | 验证码登录(含自动注册) | ✅ |
| /api/auth/sms/send | POST | 发送验证码 | ✅ |
| /api/auth/password/reset/verify | POST | 验证重置密码验证码 | ✅ |
| /api/auth/password/reset/confirm | POST | 确认重置密码 | ✅ |
| /api/auth/payment-password/set | POST | 设置支付密码 | ✅ |
| /api/auth/payment-password/update | POST | 修改支付密码 | ✅ |
| /api/auth/payment-password/verify | POST | 验证支付密码 | ✅ |
| /api/auth/token/refresh | POST | 刷新Token | ✅ |
| /api/auth/logout | POST | 登出 | ✅ |
| /api/auth/check/phone | POST | 检查手机号是否已注册 | ✅ |

**说明**:
- 不需要单独的注册接口，验证码登录自动处理注册
- 所有接口都已在文档中定义

---

## RPC接口清单

### AuthService提供 (被其他服务调用)

```java
/**
 * 验证Token有效性
 * @param token AccessToken
 * @return 用户ID,无效返回null
 */
Long validateToken(String token);

/**
 * 验证支付密码
 * @param userId 用户ID
 * @param paymentPassword 支付密码(明文)
 * @return 是否正确
 */
Boolean verifyPaymentPassword(Long userId, String paymentPassword);
```

---

## 测试要点

### 功能测试
- [ ] 注册流程完整
- [ ] 登录成功获取Token
- [ ] Token验证正确
- [ ] 找回密码流程正常
- [ ] 支付密码设置和验证
- [ ] 第三方登录成功

### 安全测试
- [ ] 密码BCrypt加密
- [ ] Token签名验证
- [ ] 验证码防暴力破解
- [ ] 登录失败次数限制
- [ ] Token过期自动失效
- [ ] 登出后Token失效

### 性能测试
- [ ] Token验证响应时间 < 50ms
- [ ] 登录接口支持500 QPS

---

## 监控告警

### 关键指标
- 登录成功率
- Token验证失败率
- 验证码发送量
- 异常登录(异地登录)

### 告警规则
- 登录成功率 < 90% → P2告警
- Token验证失败率 > 5% → P1告警
- 验证码1分钟发送量 > 100 → P2告警
- 检测到异常登录 → 通知用户

---

## 完成状态

### Phase 1: 核心文档创建 ✅ 已完成
- [x] 创建 01-密码登录页面.md
- [x] 创建 02-验证码登录页面.md
- [x] 创建 03-忘记密码页面.md
- [x] 创建 04-设置支付密码页面.md
- [x] 创建 认证服务接口文档.md (Backend)

**文档统计**:
- 前端页面文档: 4个 ✅
- 后端服务文档: 1个 ✅
- 总API数: 11个对外API + 2个RPC接口

### Phase 2: 功能开发 (待实施)
- [ ] 实现密码登录功能
- [ ] 实现验证码登录和自动注册
- [ ] 实现忘记密码流程
- [ ] 实现支付密码设置/验证
- [ ] 实现Token管理(生成/刷新/黑名单)
- [ ] 集成阿里云短信服务
- [ ] 集成UserService RPC调用

### Phase 3: 安全加固 (待实施)
- [ ] 实施密码加密(BCrypt强度12)
- [ ] 实施JWT Token签名
- [ ] 实施验证码防暴力破解
- [ ] 实施支付密码错误锁定
- [ ] 添加登录风控规则
- [ ] 完善审计日志

---

**⚠️ 重要提示**:
AuthService是整个系统的安全基石,必须严格遵循安全规范,所有密码明文传输必须使用HTTPS,Token密钥严格保密。

**模块维护者**: 安全团队
**最后更新**: 2025-11-14
