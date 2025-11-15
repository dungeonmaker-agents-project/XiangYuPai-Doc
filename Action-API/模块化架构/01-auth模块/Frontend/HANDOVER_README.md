# 前端交接文档 (Frontend Handover Document)

## 📦 交接概览

**交接日期**: 2025-11-14
**模块名称**: 01-auth模块（认证模块）
**后端状态**: ✅ 开发完成，已通过 105+ 测试用例验证
**前端状态**: ⏳ 待开发
**下次对接**: 生产上线前最终验证

---

## 🎯 交接内容

本次交接包含完整的认证模块前端开发所需的全部文档和接口说明。

### 📂 文档清单

| 文档名称 | 路径 | 描述 | 优先级 |
|---------|------|------|--------|
| **INTERFACE_CORRECTIONS.md** | `Frontend/` | ⚠️ **接口纠正文档（必读）** | 🔴 最高 |
| 01-密码登录页面.md | `Frontend/` | 密码登录页面UI和交互规范 | 🟢 高 |
| 02-验证码登录页面.md | `Frontend/` | SMS登录页面（含自动注册） | 🟢 高 |
| 03-忘记密码页面.md | `Frontend/` | 忘记密码3步流程 | 🟢 高 |
| 04-设置支付密码页面.md | `Frontend/` | 支付密码设置/修改 | 🟡 中 |
| 认证服务接口文档.md | `Backend/` | 后端完整接口说明（参考） | 🟡 中 |

---

## ⚠️ 重要：必须先阅读的文档

### 1. INTERFACE_CORRECTIONS.md（接口纠正文档）

**为什么必须先读**:
原始前端文档（01-04）中的接口定义与后端实际实现存在差异。`INTERFACE_CORRECTIONS.md` 列出了所有差异和纠正内容。

**主要纠正点**:
- ❌ `phoneNumber` → ✅ `mobile`
- ❌ `token` → ✅ `accessToken`
- ❌ `purpose: "LOGIN"` → ✅ `type: "login"`
- ❌ `/api/auth/sms/send` → ✅ `/api/sms/send`
- 新增字段：`refreshToken`, `expireIn`, `isNewUser`

**开发流程**:
```
1. 阅读 INTERFACE_CORRECTIONS.md（30分钟）
   ↓
2. 阅读对应的页面文档（01-04）
   ↓
3. 开发时以 INTERFACE_CORRECTIONS.md 为准
```

---

## 📋 接口快速参考

### 核心接口（11个）

| 接口 | 方法 | 路径 | 是否需要Token | 说明 |
|-----|------|------|-------------|------|
| 密码登录 | POST | `/api/auth/login/password` | ❌ | 手机号+密码登录 |
| SMS登录 | POST | `/api/auth/login/sms` | ❌ | 验证码登录+自动注册 |
| 发送验证码 | POST | `/api/sms/send` | ❌ | 发送登录/重置验证码 |
| 验证验证码 | POST | `/api/auth/password/reset/verify` | ❌ | 验证重置密码验证码 |
| 重置密码 | POST | `/api/auth/password/reset/confirm` | ❌ | 确认重置新密码 |
| 设置支付密码 | POST | `/api/auth/payment-password/set` | ✅ | 首次设置6位支付密码 |
| 修改支付密码 | POST | `/api/auth/payment-password/update` | ✅ | 修改已有支付密码 |
| 验证支付密码 | POST | `/api/auth/payment-password/verify` | ✅ | 支付时验证密码 |
| 刷新Token | POST | `/api/auth/token/refresh` | ❌ | 使用refreshToken获取新token |
| 登出 | POST | `/api/auth/logout` | ✅ | 用户登出 |
| 检查手机号 | POST | `/api/auth/check/phone` | ❌ | 检查手机号是否注册 |

### 关键字段映射

| 前端文档中的字段 | 实际后端字段 | 适用接口 |
|----------------|-------------|---------|
| `phoneNumber` | `mobile` | 登录、SMS相关接口 |
| `token` (响应) | `accessToken` | 所有登录接口 |
| `purpose` | `type` | SMS发送接口 |
| `countryCode` (SMS发送) | `region` | SMS发送接口 |

---

## 🔑 核心功能说明

### 功能 1: SMS 登录自动注册

**场景**: 未注册用户通过验证码登录时自动创建账号

**关键字段**: `isNewUser` (boolean)

**前端处理**:
```typescript
if (result.data.isNewUser) {
  // 新用户 → 跳转完善资料页面
  router.push('/user/profile/edit');
} else {
  // 老用户 → 跳转首页
  router.push('/home');
}
```

**为什么重要**:
- 新用户需要完善昵称、头像等信息
- 老用户直接进入主页
- `isNewUser` 字段是业务流程的关键分支点

---

### 功能 2: Token 管理

**AccessToken**:
- 用途：访问受保护的API
- 有效期：7200秒（2小时）
- 携带方式：`Authorization: Bearer <accessToken>`

**RefreshToken**:
- 用途：刷新 accessToken
- 有效期：更长（具体由后端配置）
- 使用场景：accessToken 过期时

**建议实现**:
```typescript
// 1. 登录后保存两个token
localStorage.setItem('accessToken', result.data.accessToken);
localStorage.setItem('refreshToken', result.data.refreshToken);

// 2. API请求拦截器
axios.interceptors.request.use(config => {
  const token = localStorage.getItem('accessToken');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// 3. 响应拦截器处理401
axios.interceptors.response.use(
  response => response,
  async error => {
    if (error.response?.status === 401) {
      // Token过期，尝试刷新
      const refreshToken = localStorage.getItem('refreshToken');
      const newTokens = await refreshAccessToken(refreshToken);
      // 重试原请求
    }
  }
);
```

---

### 功能 3: SMS 验证码倒计时

**后端返回数据**:
```typescript
{
  codeId: "abc123",
  expiresIn: 300,      // 验证码5分钟有效
  nextSendTime: 60,    // 60秒后可重发
  mobile: "13800138000"
}
```

**前端实现建议**:
```typescript
// 使用 nextSendTime 而非固定60秒
const [countdown, setCountdown] = useState(0);

const handleSendSms = async () => {
  const response = await sendSms({ mobile, type: 'login' });
  if (response.code === 200) {
    // 使用后端返回的时间
    setCountdown(response.data.nextSendTime);
    startCountdown();
  }
};
```

---

### 功能 4: 忘记密码 3 步流程

**流程图**:
```
页面1: 输入手机号 → 获取验证码
  ↓
页面2: 输入验证码 → 验证验证码
  ↓
页面3: 设置新密码 → 完成重置
  ↓
返回登录页
```

**数据传递**:
```typescript
// 使用状态管理或路由参数传递
interface ResetPasswordState {
  countryCode: string;      // 页面1 → 页面2 → 页面3
  mobile: string;           // 页面1 → 页面2 → 页面3
  verificationCode: string; // 页面2 → 页面3
}
```

**重要**:
- 验证码需要在页面3重新发送给后端（二次验证）
- 完成后清除所有临时数据

---

## 🔒 安全注意事项

### 1. 密码输入

```typescript
// ✅ 正确：默认隐藏
<input type="password" />

// ❌ 错误：不能默认明文
<input type="text" />
```

### 2. Token 存储

```typescript
// ✅ 推荐：localStorage
localStorage.setItem('accessToken', token);

// ⚠️ 不推荐：sessionStorage（页面关闭即失效）
// ❌ 禁止：明文存储在Cookie（CSRF风险）
```

### 3. 敏感信息

```typescript
// ❌ 禁止：在控制台打印token
console.log('token:', accessToken);

// ❌ 禁止：在URL中传递token
router.push(`/home?token=${accessToken}`);

// ✅ 正确：仅在HTTP头中传递
headers: { Authorization: `Bearer ${accessToken}` }
```

---

## 🧪 测试建议

### 测试账号

后端已准备测试用户（参考 `TEST_DOCUMENTATION.md`）:

```typescript
// 已注册用户1
const USER1 = {
  mobile: '13800138000',
  password: 'password123',
  userId: 1001,
  nickname: '测试用户1'
};

// 已注册用户2
const USER2 = {
  mobile: '13800138001',
  password: 'test456789',
  userId: 1002
};

// 新用户（用于测试自动注册）
const NEW_USER = {
  mobile: '13900139000'
};

// 测试验证码（开发环境）
const TEST_CODE = '123456';
```

### 测试场景

**必测场景**:
1. ✅ 密码登录成功
2. ✅ 密码登录失败（错误密码）
3. ✅ SMS登录-新用户自动注册（isNewUser=true）
4. ✅ SMS登录-老用户（isNewUser=false）
5. ✅ SMS验证码倒计时
6. ✅ 忘记密码完整流程
7. ✅ 设置支付密码
8. ✅ Token过期自动刷新
9. ✅ 登出后Token失效

**边界测试**:
1. 手机号格式验证
2. 密码长度验证
3. 网络异常处理
4. 快速重复点击防抖

---

## 📊 开发优先级

### P0（最高优先级，必须实现）
- [x] 密码登录页面
- [x] SMS登录页面（含自动注册）
- [x] 忘记密码流程

### P1（高优先级）
- [ ] Token刷新机制
- [ ] 登出功能
- [ ] 设置支付密码

### P2（中优先级）
- [ ] 修改支付密码
- [ ] 手机号注册状态检查

---

## 🚀 开发建议

### 1. 技术栈建议

**状态管理**:
```typescript
// 推荐使用 Redux/Zustand/Jotai
interface AuthState {
  isAuthenticated: boolean;
  user: User | null;
  token: string | null;
  refreshToken: string | null;
}
```

**网络请求**:
```typescript
// 推荐使用 axios 并配置拦截器
import axios from 'axios';

const api = axios.create({
  baseURL: 'https://api.example.com',
  timeout: 10000
});

// 请求拦截器：自动添加token
api.interceptors.request.use(config => {
  const token = localStorage.getItem('accessToken');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// 响应拦截器：自动刷新token
api.interceptors.response.use(
  response => response,
  async error => {
    if (error.response?.status === 401) {
      // 处理token过期
    }
    return Promise.reject(error);
  }
);
```

### 2. 表单验证

```typescript
// 手机号验证（+86）
const validateMobile = (mobile: string) => {
  return /^1[3-9]\d{9}$/.test(mobile);
};

// 密码验证
const validatePassword = (password: string) => {
  if (password.length < 6 || password.length > 20) {
    return '密码长度为6-20位';
  }
  if (/^\d+$/.test(password)) {
    return '密码不能为纯数字';
  }
  return null;
};

// 验证码验证
const validateCode = (code: string) => {
  return /^\d{6}$/.test(code);
};
```

### 3. 错误处理

```typescript
// 统一错误处理函数
const handleApiError = (error: any) => {
  if (error.response) {
    const { code, message } = error.response.data;
    switch (code) {
      case 400:
        showToast('请检查输入信息');
        break;
      case 401:
        showToast(message || '认证失败');
        break;
      case 429:
        showToast(message || '操作过于频繁');
        break;
      case 500:
        showToast('服务器错误，请稍后重试');
        break;
      default:
        showToast(message || '操作失败');
    }
  } else if (error.request) {
    showToast('网络连接失败，请检查网络设置');
  } else {
    showToast('请求失败，请稍后重试');
  }
};
```

---

## 📞 技术支持

### 开发期间

如遇到以下问题，请及时联系后端团队：

1. **接口返回数据与文档不符**
   - 检查是否已阅读 `INTERFACE_CORRECTIONS.md`
   - 确认使用的是纠正后的字段名

2. **接口调用失败（4xx/5xx错误）**
   - 检查请求参数是否正确
   - 检查是否携带了必需的 Authorization 头
   - 查看后端日志获取详细错误信息

3. **业务逻辑不清楚**
   - 参考后端测试用例（105+ 测试场景）
   - 查看 `认证服务接口文档.md` 中的详细说明

### 联系方式

- **后端负责人**: XyPai Backend Team
- **文档维护**: Claude AI Assistant
- **问题反馈**: 通过项目管理工具或邮件

---

## ✅ 交接确认清单

前端团队收到本文档后，请确认以下事项：

- [ ] 已收到所有文档（6个文件）
- [ ] 已阅读 `INTERFACE_CORRECTIONS.md`
- [ ] 理解 `isNewUser` 字段的作用
- [ ] 理解 Token 管理机制
- [ ] 理解 SMS 验证码流程
- [ ] 知道如何处理错误响应
- [ ] 知道测试账号和验证码
- [ ] 明确开发优先级
- [ ] 有技术支持联系方式

---

## 📅 重要时间节点

| 时间节点 | 说明 |
|---------|------|
| 2025-11-14 | 后端开发完成，文档交接 |
| 前端开发期间 | 可随时咨询后端团队 |
| 前端自测完成后 | 与后端进行联调测试 |
| 生产上线前 | 最终接口验证和性能测试 |

---

## 🎉 总结

本次交接包含：
- ✅ 11个完整接口实现
- ✅ 105+ 测试用例验证
- ✅ 完整的UI和交互规范
- ✅ 详细的接口纠正说明
- ✅ 开发建议和最佳实践

**祝前端开发顺利！如有问题随时联系。**

---

**最后更新**: 2025-11-14
**文档版本**: v1.0
**维护者**: XyPai Backend Team
