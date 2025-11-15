# 🗄️ Alice - 认证模块数据库设计

> **设计参考**: PL.md v7.1 (第289-651行)  
> **数据库**: xypai_auth  
> **表数量**: 5张  
> **字段总数**: 71个  
> **索引总数**: 21个

---

## 📊 表结构概览

| 表名 | 字段数 | 索引数 | 预估行数(万用户) | 说明 |
|------|--------|--------|-----------------|------|
| login_session | 22 | 6 | 10万 | 登录会话表 |
| sms_verification | 15 | 4 | 90万(30天) | 短信验证码表 |
| user_device | 18 | 4 | 5万 | 用户设备表 |
| phone_verify_limit | 9 | 3 | 1万 | 手机号验证限制表 |
| token_blacklist | 7 | 4 | 1万 | JWT令牌黑名单表 |

---

## 📋 详细设计

### 1. login_session (登录会话表)

**设计参考**: PL.md 第291-340行

**核心字段**:
- `access_token` (VARCHAR 500) - JWT访问令牌，24小时有效 ⭐
- `refresh_token` (VARCHAR 500) - JWT刷新令牌，7天有效 ⭐
- `user_id` + `device_id` - 支持多设备登录
- `last_active_time` - 心跳保活机制

**核心索引**:
- `uk_access_token` - Token验证（高频，<5ms）⭐
- `idx_user_status` - 用户会话查询

**核心查询**:
```sql
-- Token验证（QPS极高）
SELECT * FROM login_session WHERE access_token = ? LIMIT 1;
-- 预期: <5ms

-- 用户会话列表
SELECT * FROM login_session 
WHERE user_id = ? AND status = 1 AND expires_at > NOW();
-- 预期: <20ms
```

---

### 2. sms_verification (短信验证码表)

**设计参考**: PL.md 第342-381行

**核心字段**:
- `sms_code` (VARCHAR 10) - 6位数字验证码
- `sms_token` (VARCHAR 64) - 防重放攻击 ⭐
- `verify_count` - 验证尝试次数（最多3次）
- `expire_time` - 5分钟有效期

**安全机制**:
- ✅ 最多3次验证尝试
- ✅ 5分钟过期
- ✅ sms_token防重放

---

### 3. user_device (用户设备表)

**设计参考**: PL.md 第426-475行

**核心功能**:
- 设备详情记录（品牌、型号、系统版本）
- 信任设备管理（30天有效期）
- 登录统计（次数、最后登录时间）

---

### 4. phone_verify_limit (防穷举表)

**设计参考**: PL.md 第594-620行

**安全策略**:
```
每日发送上限: 10次
每日验证上限: 30次
封禁时长: 24小时
重置时间: 每日0点自动
```

---

### 5. token_blacklist (Token黑名单表)

**设计参考**: PL.md 第568-591行

**使用场景**:
- user_logout - 用户主动登出
- remote_logout - 远程注销其他设备
- admin_ban - 管理员封禁
- security_issue - 安全异常

---

## 🔗 表关系

```
xypai_user.user (Bob负责)
    ↓ 1:N
    ├─> login_session (Alice)
    │     ├─ device_id → user_device
    │     └─ access_token → token_blacklist
    │
    ├─> user_device (Alice)
    │
    └─> sms_verification (Alice)
          └─ mobile → phone_verify_limit
```

---

## 📈 容量估算

```
1万用户: 约380MB
10万用户: 约3.8GB
100万用户: 约38GB

清理策略:
- login_session: 保留90天
- sms_verification: 保留30天
- token_blacklist: 过期自动清理
```

---

## 🎯 性能指标

| 操作 | 预期时间 | 索引 |
|------|---------|------|
| Token验证 | <5ms | uk_access_token |
| 会话查询 | <20ms | idx_user_status |
| 验证码查询 | <10ms | idx_mobile_type |
| 黑名单检查 | <3ms | uk_token |

---

**设计人**: Alice | **审核**: Jack (DBA) | **版本**: v2.0

