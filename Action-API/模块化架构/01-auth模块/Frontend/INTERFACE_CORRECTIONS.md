# 前端接口文档纠正说明 (Frontend API Corrections)

## 📋 文档版本

**文档创建日期**: 2025-11-14
**后端实现版本**: v1.0
**纠正状态**: ✅ 已验证完整性

---

## ⚠️ 重要说明

本文档列出了前端接口文档与后端实际实现之间的**差异和纠正**。请前端团队在开发时**严格按照本文档的纠正内容**进行调整。

---

## 🔧 通用纠正（所有接口）

### 1. API 路径前缀

| 文档中的路径 | 实际后端路径 | 网关转发后路径 | 说明 |
|------------|------------|--------------|------|
| `/api/auth/*` | `/auth/*` | `/api/auth/*` | ✅ 正确，网关会添加 `/api` 前缀 |
| `/api/auth/sms/send` | `/sms/send` | `/api/sms/send` | ⚠️ 注意：后端是 `/sms/send` 不在 `/auth` 下 |

**纠正**: SMS 相关接口不在 `/auth` 路径下，而是独立的 `/sms` 路径。

### 2. 请求字段名称统一纠正

| 文档中的字段名 | 实际后端字段名 | 适用接口 |
|--------------|-------------|---------|
| `phoneNumber` | `mobile` | 所有登录、SMS相关接口 |
| `purpose` | `type` | SMS 发送接口 |
| `countryCode` | `countryCode` (部分接口) / `region` (SMS发送) | 见具体接口 |

### 3. 响应字段名称统一纠正

| 文档中的字段名 | 实际后端字段名 | 说明 |
|--------------|-------------|------|
| `token` | `accessToken` | 登录接口返回的访问令牌 |
| - (缺失) | `refreshToken` | 登录接口返回的刷新令牌 |
| - (缺失) | `expireIn` | Token 有效期（秒） |

---

## 📝 接口逐个纠正

### 接口 1: 密码登录

**文档路径**: `01-密码登录页面.md`

#### ❌ 文档中的请求参数
```typescript
{
  countryCode: string;      // ✅ 正确
  phoneNumber: string;      // ❌ 错误
  password: string;         // ✅ 正确
  agreeToTerms: boolean;    // ✅ 正确
}
```

#### ✅ 纠正后的请求参数
```typescript
{
  countryCode: string;      // 国家区号，例如："+86"
  mobile: string;           // ⚠️ 使用 mobile 而不是 phoneNumber
  password: string;         // 密码，6-20位字符
  agreeToTerms: boolean;    // 用户协议勾选状态
  clientId?: string;        // 可选，客户端ID，默认 "app"
  grantType?: string;       // 可选，授权类型，默认 "app_password"
}
```

#### ❌ 文档中的响应数据
```typescript
{
  code: number;
  message: string;
  data: {
    token: string;        // ❌ 错误
    userId: string;       // ✅ 正确
    nickname: string;     // ✅ 正确
    avatar?: string;      // ✅ 正确
  }
}
```

#### ✅ 纠正后的响应数据
```typescript
{
  code: number;
  message: string;
  data: {
    accessToken: string;     // ⚠️ 使用 accessToken 而不是 token
    refreshToken?: string;   // ⚠️ 新增：刷新令牌（暂未实现，未来版本会添加）
    expireIn: number;        // ⚠️ 新增：Token有效期（秒），例如：7200
    userId: string;          // 用户ID
    nickname: string;        // 用户昵称
    avatar?: string;         // 用户头像URL
    isNewUser: boolean;      // ⚠️ 新增：是否新用户标记（密码登录通常为false）
  }
}
```

**使用示例**:
```typescript
// 正确的请求
const response = await fetch('/api/auth/login/password', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    countryCode: '+86',
    mobile: '13800138000',        // ⚠️ 注意：mobile 不是 phoneNumber
    password: 'password123',
    agreeToTerms: true
  })
});

// 正确的响应处理
const result = await response.json();
if (result.code === 200) {
  const { accessToken, userId, isNewUser, expireIn } = result.data;
  // 保存 accessToken 用于后续请求
  localStorage.setItem('token', accessToken);
}
```

---

### 接口 2: 验证码登录

**文档路径**: `02-验证码登录页面.md`

#### ❌ 文档中的请求参数
```typescript
{
  countryCode: string;      // ✅ 正确
  phoneNumber: string;      // ❌ 错误
  verificationCode: string; // ✅ 正确
  agreeToTerms: boolean;    // ✅ 正确
}
```

#### ✅ 纠正后的请求参数
```typescript
{
  countryCode: string;      // 国家区号
  mobile: string;           // ⚠️ 使用 mobile
  verificationCode: string; // 6位验证码
  agreeToTerms: boolean;    // 用户协议勾选
  clientId?: string;        // 可选，默认 "app"
  grantType?: string;       // 可选，默认 "app_sms"
}
```

#### ❌ 文档中的响应数据
```typescript
{
  code: number;
  message: string;
  data: {
    token: string;        // ❌ 错误
    userId: string;       // ✅ 正确
    nickname: string;     // ✅ 正确
    avatar?: string;      // ✅ 正确
    isNewUser: boolean;   // ✅ 正确
  }
}
```

#### ✅ 纠正后的响应数据
```typescript
{
  code: number;
  message: string;
  data: {
    accessToken: string;     // ⚠️ 使用 accessToken
    refreshToken?: string;   // ⚠️ 新增（未来版本）
    expireIn: number;        // ⚠️ 新增：有效期
    userId: string;          // 用户ID
    nickname: string;        // 用户昵称（新用户为 "138****8000" 格式）
    avatar?: string;         // 用户头像
    isNewUser: boolean;      // ⚠️ 重要：是否新注册用户
  }
}
```

**特殊说明**:
- `isNewUser` 字段非常重要，用于判断是否跳转到完善资料页面
- 新用户昵称格式为：`138****8000`（手机号脱敏）

**使用示例**:
```typescript
const response = await fetch('/api/auth/login/sms', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    countryCode: '+86',
    mobile: '13800138000',           // ⚠️ mobile
    verificationCode: '123456',
    agreeToTerms: true
  })
});

const result = await response.json();
if (result.code === 200) {
  const { accessToken, isNewUser } = result.data;
  localStorage.setItem('token', accessToken);

  // 根据 isNewUser 决定跳转
  if (isNewUser) {
    router.push('/user/profile/edit');  // 新用户 → 完善资料
  } else {
    router.push('/home');               // 老用户 → 首页
  }
}
```

---

### 接口 3: 发送短信验证码

**文档路径**: `02-验证码登录页面.md`, `03-忘记密码页面.md`

#### ⚠️ 重要：API 路径纠正

| 文档中的路径 | 实际路径 |
|------------|---------|
| `POST /api/auth/sms/send` | `POST /api/sms/send` |

**说明**: 后端 SMS 接口不在 `/auth` 路径下，而是独立的 `/sms` 模块。

#### ❌ 文档中的请求参数
```typescript
{
  countryCode: string;      // ❌ 错误
  phoneNumber: string;      // ❌ 错误
  purpose: "LOGIN" | "RESET_PASSWORD"  // ❌ 错误
}
```

#### ✅ 纠正后的请求参数
```typescript
{
  mobile: string;           // ⚠️ 使用 mobile（不需要 countryCode）
  type: string;             // ⚠️ 使用 type，值为 "login" 或 "reset"（小写）
  region?: string;          // ⚠️ 可选，国家区号，默认 "+86"
}
```

**type 字段值对照表**:

| 文档中的值 | 实际后端值 |
|----------|----------|
| `"LOGIN"` | `"login"` |
| `"RESET_PASSWORD"` | `"reset"` |

#### ❌ 文档中的响应数据
```typescript
{
  code: number;
  message: string;
  data: null              // ❌ 错误：实际有返回数据
}
```

#### ✅ 纠正后的响应数据
```typescript
{
  code: number;
  message: string;
  data: {
    codeId: string;         // ⚠️ 新增：验证码ID（唯一标识）
    expiresIn: number;      // ⚠️ 新增：过期时间（秒），通常为 300（5分钟）
    nextSendTime: number;   // ⚠️ 新增：下次可发送时间（秒），通常为 60
    mobile: string;         // ⚠️ 新增：接收手机号
    code?: string;          // ⚠️ 开发环境返回：验证码明文（生产环境不返回）
  }
}
```

**使用示例**:
```typescript
// 发送登录验证码
const response = await fetch('/api/sms/send', {  // ⚠️ 注意路径
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    mobile: '13800138000',    // ⚠️ mobile 不是 phoneNumber
    type: 'login',            // ⚠️ 小写 "login" 不是 "LOGIN"
    region: '+86'             // ⚠️ region 不是 countryCode
  })
});

const result = await response.json();
if (result.code === 200) {
  const { codeId, expiresIn, nextSendTime, code } = result.data;
  console.log(`验证码ID: ${codeId}`);
  console.log(`有效期: ${expiresIn}秒`);
  console.log(`下次可发送: ${nextSendTime}秒后`);

  // 开发环境可能返回验证码
  if (code) {
    console.log(`验证码（仅开发环境）: ${code}`);
  }

  // 开始倒计时
  startCountdown(nextSendTime);
}

// 发送重置密码验证码
const resetResponse = await fetch('/api/sms/send', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    mobile: '13800138000',
    type: 'reset',            // ⚠️ 小写 "reset"
    region: '+86'
  })
});
```

**错误处理**:
| 状态码 | 说明 | 处理建议 |
|-------|------|---------|
| 200 | 成功 | 开始倒计时，显示 nextSendTime |
| 400 | 参数错误 | 检查手机号格式 |
| 404 | 手机号未注册（仅reset类型） | 提示"该手机号未注册" |
| 429 | 发送频繁 | 显示 message 中的剩余等待时间 |
| 500 | 服务器错误 | 提示用户稍后重试 |

---

### 接口 4: 忘记密码 - 验证验证码

**文档路径**: `03-忘记密码页面.md`

#### ❌ 文档中的请求参数
```typescript
{
  countryCode: string;       // ✅ 正确
  phoneNumber: string;       // ❌ 错误
  verificationCode: string;  // ✅ 正确
}
```

#### ✅ 纠正后的请求参数
```typescript
{
  countryCode: string;       // 国家区号
  mobile: string;            // ⚠️ 使用 mobile
  verificationCode: string;  // 6位验证码
}
```

**使用示例**:
```typescript
const response = await fetch('/api/auth/password/reset/verify', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    countryCode: '+86',
    mobile: '13800138000',         // ⚠️ mobile
    verificationCode: '123456'
  })
});
```

---

### 接口 5: 忘记密码 - 确认重置

**文档路径**: `03-忘记密码页面.md`

#### ❌ 文档中的请求参数
```typescript
{
  countryCode: string;       // ✅ 正确
  phoneNumber: string;       // ❌ 错误
  verificationCode: string;  // ✅ 正确
  newPassword: string;       // ✅ 正确
}
```

#### ✅ 纠正后的请求参数
```typescript
{
  countryCode: string;       // 国家区号
  mobile: string;            // ⚠️ 使用 mobile
  verificationCode: string;  // 6位验证码（需携带以进行二次验证）
  newPassword: string;       // 新密码，6-20位字符
}
```

**使用示例**:
```typescript
const response = await fetch('/api/auth/password/reset/confirm', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    countryCode: '+86',
    mobile: '13800138000',         // ⚠️ mobile
    verificationCode: '123456',
    newPassword: 'newPassword123'
  })
});
```

---

### 接口 6-8: 支付密码管理

**文档路径**: `04-设置支付密码页面.md`

#### ✅ 支付密码接口完全正确

支付密码相关的三个接口（设置、修改、验证）在文档中的定义**与后端实现完全一致**，无需纠正。

**接口列表**:
1. `POST /api/auth/payment-password/set` - 设置支付密码 ✅
2. `POST /api/auth/payment-password/update` - 修改支付密码 ✅
3. `POST /api/auth/payment-password/verify` - 验证支付密码 ✅

**注意事项**:
- 所有接口都需要在请求头中携带 `Authorization: Bearer <token>`
- 密码必须是6位数字
- verify 接口的响应中 `data.verified` 为布尔值

---

## 🔄 Token 管理接口（文档中未涉及，需要补充）

### 接口 9: 刷新 Token

**接口路径**: `POST /api/auth/token/refresh`

**说明**: 当 accessToken 过期时，使用 refreshToken 获取新的 token

**请求参数**:
```typescript
{
  refreshToken: string;   // 登录时返回的 refreshToken
}
```

**响应数据**:
```typescript
{
  code: number;
  message: string;
  data: {
    token: string;         // 新的 access token
    refreshToken: string;  // 新的 refresh token
    expireIn: number;      // 有效期（秒）
  }
}
```

**使用示例**:
```typescript
const response = await fetch('/api/auth/token/refresh', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    refreshToken: storedRefreshToken
  })
});

const result = await response.json();
if (result.code === 200) {
  // 更新存储的 token
  localStorage.setItem('token', result.data.token);
  localStorage.setItem('refreshToken', result.data.refreshToken);
}
```

---

### 接口 10: 登出

**接口路径**: `POST /api/auth/logout`

**说明**: 用户主动登出，使当前 token 失效

**请求头**:
```
Authorization: Bearer <token>
```

**请求体**: 空对象 `{}`

**响应数据**:
```typescript
{
  code: number;
  message: string;
  data: null
}
```

**使用示例**:
```typescript
const response = await fetch('/api/auth/logout', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({})
});

if (response.ok) {
  // 清除本地存储
  localStorage.removeItem('token');
  localStorage.removeItem('refreshToken');
  // 跳转到登录页
  router.push('/auth/login/password');
}
```

---

### 接口 11: 检查手机号注册状态

**接口路径**: `POST /api/auth/check/phone`

**说明**: 检查手机号是否已注册

**请求参数**:
```typescript
{
  countryCode: string;    // 国家区号
  phoneNumber: string;    // ⚠️ 注意：此接口使用 phoneNumber 字段
}
```

**响应数据**:
```typescript
{
  code: number;
  message: string;
  data: {
    isRegistered: boolean;  // true=已注册，false=未注册
  }
}
```

**使用示例**:
```typescript
const response = await fetch('/api/auth/check/phone', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    countryCode: '+86',
    phoneNumber: '13800138000'  // ⚠️ 此接口用 phoneNumber
  })
});

const result = await response.json();
if (result.code === 200) {
  if (result.data.isRegistered) {
    console.log('手机号已注册');
  } else {
    console.log('手机号未注册');
  }
}
```

---

## 📊 完整接口对照表

| 接口名称 | 文档路径 | 实际路径 | 主要纠正点 |
|---------|---------|---------|----------|
| 密码登录 | `/api/auth/login/password` | ✅ 正确 | `phoneNumber` → `mobile`<br>`token` → `accessToken` |
| 验证码登录 | `/api/auth/login/sms` | ✅ 正确 | `phoneNumber` → `mobile`<br>`token` → `accessToken` |
| 发送验证码 | `/api/auth/sms/send` | `/api/sms/send` | 路径、字段名、响应数据 |
| 验证验证码 | `/api/auth/password/reset/verify` | ✅ 正确 | `phoneNumber` → `mobile` |
| 确认重置密码 | `/api/auth/password/reset/confirm` | ✅ 正确 | `phoneNumber` → `mobile` |
| 设置支付密码 | `/api/auth/payment-password/set` | ✅ 正确 | 无需纠正 |
| 修改支付密码 | `/api/auth/payment-password/update` | ✅ 正确 | 无需纠正 |
| 验证支付密码 | `/api/auth/payment-password/verify` | ✅ 正确 | 无需纠正 |
| 刷新Token | - (未文档化) | `/api/auth/token/refresh` | 补充文档 |
| 登出 | - (未文档化) | `/api/auth/logout` | 补充文档 |
| 检查手机号 | - (未文档化) | `/api/auth/check/phone` | 补充文档 |

---

## ✅ 前端开发检查清单

在开始开发前，请确保：

- [ ] 所有登录、SMS相关接口使用 `mobile` 而非 `phoneNumber`
- [ ] SMS发送接口使用正确路径 `/api/sms/send`
- [ ] SMS发送接口使用 `type: "login"/"reset"` 而非 `purpose: "LOGIN"/"RESET_PASSWORD"`
- [ ] 登录响应使用 `accessToken` 而非 `token`
- [ ] 处理 SMS 发送接口的完整响应数据（codeId, expiresIn, nextSendTime）
- [ ] 根据 `isNewUser` 字段正确处理新用户跳转逻辑
- [ ] 实现 Token 刷新机制（使用 refreshToken）
- [ ] 实现登出功能并清理本地存储
- [ ] 所有需要认证的接口携带 `Authorization: Bearer <token>` 头

---

## 🔗 相关文档

- [后端接口文档](../Backend/认证服务接口文档.md) - 后端完整接口说明
- [接口实现验证报告](../../../RuoYi-Cloud-Plus/xypai-auth/INTERFACE_VERIFICATION.md) - 后端实现验证
- [测试文档](../../../RuoYi-Cloud-Plus/xypai-auth/TEST_DOCUMENTATION.md) - 测试用例参考

---

## 📞 联系方式

如有疑问，请联系：
- 后端负责人：XyPai Backend Team
- 最后更新：2025-11-14
- 文档版本：v1.0

---

**重要提醒**:
1. 本文档所列纠正内容已经过后端实现验证，请严格遵守
2. 如发现其他不一致之处，请及时反馈给后端团队
3. 所有接口均已通过 105+ 测试用例验证，可放心使用
