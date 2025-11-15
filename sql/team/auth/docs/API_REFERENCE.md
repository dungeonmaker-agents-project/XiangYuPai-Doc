# 📡 Alice - 认证模块API参考

> **服务**: xypai-auth  
> **端口**: 9405  
> **基础路径**: /api/v1/auth  
> **API总数**: 20个（9基础 + 6设备 + 5会话）

---

## 🔐 基础认证API（9个）

### 1. 密码登录
```http
POST /api/v1/auth/login
Content-Type: application/json

Request:
{
  "username": "alice_dev",
  "password": "123456",
  "clientType": "web",
  "deviceId": "test_device_001"
}

Response:
{
  "code": 200,
  "data": {
    "accessToken": "eyJhbGci...",
    "refreshToken": "eyJhbGci...",
    "expiresIn": 86400,
    "userInfo": {...}
  }
}
```

### 2. 短信登录
```http
POST /api/v1/auth/login/sms

Request:
{
  "mobile": "13800138000",
  "smsCode": "123456",
  "clientType": "app",
  "deviceId": "iphone_001"
}
```

### 3. 发送验证码
```http
POST /api/v1/auth/sms/send

Request:
{
  "mobile": "13800138000",
  "type": "login"
}
```

### 4-9. 其他接口
- POST /api/v1/auth/refresh - Token刷新
- POST /api/v1/auth/logout - 用户登出
- GET /api/v1/auth/verify - Token验证
- POST /api/v1/auth/sms/verify - 验证验证码
- POST /api/v1/auth/heartbeat - 心跳保活 🆕
- GET /api/v1/auth/health - 健康检查

---

## 📱 设备管理API（6个）

### 1. 查询设备列表
```http
GET /api/v1/auth/devices
Authorization: Bearer {accessToken}

Response:
{
  "code": 200,
  "data": [
    {
      "id": 1,
      "deviceId": "alice_iphone_13pro",
      "deviceName": "Alice的iPhone 13 Pro",
      "isTrusted": true,
      "loginCount": 156,
      "isCurrent": true
    }
  ]
}
```

### 2-6. 其他接口
- GET /api/v1/auth/devices/trusted - 信任设备列表
- POST /api/v1/auth/device/{id}/trust - 设置信任
- DELETE /api/v1/auth/device/{id}/trust - 取消信任
- DELETE /api/v1/auth/device/{id} - 注销设备
- DELETE /api/v1/auth/device/{id}/delete - 删除设备

---

## 🔄 会话管理API（5个）

### 1. 查询会话列表
```http
GET /api/v1/auth/sessions
Authorization: Bearer {accessToken}

Response:
{
  "code": 200,
  "data": [
    {
      "id": 1001,
      "deviceName": "iPhone 13 Pro",
      "loginIp": "120.244.xxx.123",
      "loginLocation": "北京 朝阳区",
      "isCurrent": true
    }
  ]
}
```

### 2-5. 其他接口
- GET /api/v1/auth/session/current - 当前会话
- DELETE /api/v1/auth/session/{id} - 注销会话
- POST /api/v1/auth/sessions/revoke-others - 注销其他会话
- GET /api/v1/auth/sessions/count - 会话统计

---

## 📖 完整API文档

**Swagger地址**: http://localhost:9405/doc.html

---

**🔌 20个API接口，功能完整！** ✅

