# check-same-token 配置指南

## 📌 什么是 check-same-token？

`check-same-token` 是 Sa-Token 的一个安全配置，用于确保请求必须经过网关，防止直接访问后端服务。

### 工作原理

```
客户端请求
    ↓
网关 (添加特殊标记 header)
    ↓
后端服务 (检查标记)
    ↓
如果 check-same-token: true 且没有标记 → 拒绝请求
```

---

## 🎯 配置策略

### ✅ 全局配置（application-common.yml）

```yaml
sa-token:
  check-same-token: true  # 全局要求必须经过网关
```

### ⚠️ 特殊服务需要覆盖

| 服务 | check-same-token | 原因 |
|-----|-----------------|------|
| **xypai-auth** | `false` ⭐ | 需要通过 Feign/Dubbo 调用其他服务 |
| **ruoyi-system** | `false` | 需要被其他服务调用（Dubbo RPC） |
| xypai-user | `true` (全局) | 只被调用，不主动调用业务服务 |
| xypai-chat | `true` (全局) | 只被调用，不主动调用业务服务 |
| xypai-content | `true` (全局) | 只被调用，不主动调用业务服务 |
| xypai-trade | `true` (全局) | 只被调用，不主动调用业务服务 |

---

## 🚨 为什么 xypai-auth 必须是 false？

### 问题场景

```
前端 → POST /xypai-auth/api/v1/auth/login
      ↓
🌐 网关 (8080)
   ├─ ✅ 检查白名单：在白名单中
   ├─ ✅ 转发到 xypai-auth
   └─ ✅ 添加网关标记
      ↓
🔧 xypai-auth (9200)
   ├─ ✅ 检查 check-same-token: false (允许)
   ├─ 🔄 需要查询用户信息
   └─ 🔄 Feign 调用 xypai-user
      ↓
      GET /api/v1/users/auth/mobile/13900000001
      ↓ ⚠️ 这是内部服务调用，不经过网关！
      ↓
🔧 xypai-user (9201)
   ├─ 如果 check-same-token: true
   ├─ ❌ 检查网关标记：没有！（因为是 Feign 直接调用）
   └─ ❌ 拒绝请求 → 返回 401 错误
      ↓
🔧 xypai-auth
   ├─ ❌ 收到 text/plain 响应（错误消息）
   ├─ ❌ 期望的是 JSON
   └─ ❌ 登录失败
```

### 解决方案

**方案A：xypai-auth 设置为 false** ⭐ **推荐**

```yaml
# xypai-auth.yml
sa-token:
  check-same-token: false  # ✅ 允许被直接调用
```

**优点：**
- ✅ 简单
- ✅ xypai-user 可以保持 check-same-token: true
- ✅ 只有 xypai-auth 需要特殊配置

**缺点：**
- ⚠️ xypai-auth 可以被直接访问（绕过网关）
- ⚠️ 依赖网关白名单和 Sa-Token 自身的登录检查来保护

**方案B：xypai-user 也设置为 false**

```yaml
# xypai-user.yml
sa-token:
  check-same-token: false
```

**缺点：**
- ❌ 所有服务都可以被直接访问
- ❌ 降低了系统安全性
- ❌ 不推荐

---

## 🔍 如何验证配置正确？

### 1. 检查 Nacos 配置

```bash
# 登录 Nacos 控制台
http://localhost:8848/nacos

# 查看配置
- xypai-auth.yml → check-same-token: false
- xypai-user.yml → 不配置（使用全局 true）
- application-common.yml → check-same-token: true
```

### 2. 测试登录流程

```bash
# 通过网关登录（正常）
curl -X POST http://localhost:8080/xypai-auth/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "13900000001",
    "password": "Test@123456",
    "clientType": "app"
  }'

# 应该返回：
# {
#   "code": 200,
#   "data": {
#     "accessToken": "...",
#     "userId": 2000,
#     ...
#   }
# }
```

### 3. 测试直接访问 xypai-user（应该被拒绝）

```bash
# 直接访问 xypai-user（如果 check-same-token: true）
curl -X GET http://localhost:9201/api/v2/user/profile/2000 \
  -H "Authorization: Bearer <token>"

# 应该返回：
# 401 或连接被拒绝（取决于服务是否暴露端口）
```

---

## 📋 配置清单

### ✅ 需要修改的配置文件

#### 1. xypai-auth.yml

```yaml
# XY相遇派认证模块配置

sa-token:
  check-same-token: false  # ✅ 认证服务必须设置为 false

# ... 其他配置
```

#### 2. xypai-user.yml

```yaml
# XY相遇派用户模块配置

# ✅ 不配置 check-same-token，使用全局配置（true）
# sa-token:
#   check-same-token: false  # ❌ 已注释

# ... 其他配置
```

#### 3. xypai-chat.yml, xypai-content.yml, xypai-trade.yml

```yaml
# ✅ 同样不配置，使用全局配置（true）
```

---

## 🔧 故障排查

### 问题1：登录失败 "用户名或密码错误"

**症状：**
```log
ERROR: Could not extract response: no suitable HttpMessageConverter found for response type 
[R<AuthUserDTO>] and content type [text/plain;charset=utf-8]
```

**原因：**
- xypai-auth 调用 xypai-user 被拦截
- xypai-user 的 `check-same-token: true` 导致内部调用失败

**解决：**
- 确保 `xypai-auth.yml` 中 `check-same-token: false`
- 重启 xypai-auth 服务

### 问题2：直接访问服务成功（不安全）

**症状：**
```bash
# 直接访问 xypai-user 成功
curl http://localhost:9201/api/v2/user/profile/2000
# 返回数据
```

**原因：**
- xypai-user 的 `check-same-token: false`

**解决：**
- 修改 `xypai-user.yml`，注释掉 `check-same-token: false`
- 重启 xypai-user 服务

### 问题3：网关没有日志

**原因：**
- 请求直接访问了后端服务，绕过了网关
- 检查前端 API 配置（应该是 localhost:8080，而不是 localhost:9201）

**解决：**
- 确认前端 `API_CONFIG.BASE_URL` 指向网关（8080）
- 确认网关已启动

---

## 📚 参考文档

- [Sa-Token 官方文档](https://sa-token.cc)
- [Sa-Token 分布式 Session](https://sa-token.cc/doc.html#/plugin/jwt-extend)
- [RuoYi-Cloud-Plus 架构文档](../../README.md)

---

## 🔄 版本历史

| 版本 | 日期 | 说明 |
|-----|------|------|
| v1.0 | 2025-01-28 | 初始版本，说明 check-same-token 配置策略 |

---

## 👨‍💻 维护者

如有问题，请联系技术团队。

