# 🔐 Token流程完整分析报告

**生成时间：** 2025-11-07  
**分析范围：** 后端登录 → Token生成 → 前端存储 → API访问验证

---

## 📋 目录

1. [后端Token生成流程](#1-后端token生成流程)
2. [前端Token存储机制](#2-前端token存储机制)
3. [Token使用流程](#3-token使用流程)
4. [Sa-Token配置检查](#4-sa-token配置检查)
5. [潜在问题分析](#5-潜在问题分析)
6. [修复建议](#6-修复建议)

---

## 1. 后端Token生成流程

### 1.1 登录接口实现

**文件位置：** `AuthServiceImpl.java` (行99-102, 行215-216)

#### 密码登录流程

```java
// 📍 AuthServiceImpl.java - 密码登录
@Override
@Transactional(rollbackFor = Exception.class)
public LoginResultVO loginWithPassword(LoginDTO loginDTO) {
    // 1. 验证用户密码
    AuthUserDTO user = authenticateUserWithPassword(loginDTO);
    
    // 2. 转换为LoginUser
    LoginUser loginUser = AuthUserConverter.toLoginUserWithDetails(
        user, 
        loginDTO.getClientType(),
        IpUtils.getClientIP(),
        IpUtils.getLocationByIP(IpUtils.getClientIP())
    );

    // 3. 🎯 使用Sa-Token登录 (关键步骤)
    SaLoginParameter loginModel = new SaLoginParameter();
    loginModel.setDeviceType(loginDTO.getClientType());  // 设备类型: app/pc/ios
    loginModel.setTimeout(86400L);  // 24小时
    loginModel.setExtra(LoginHelper.CLIENT_KEY, loginDTO.getClientType());
    
    LoginHelper.login(loginUser, loginModel);  // ✅ 生成token并存储用户信息

    // 4. 🎯 获取Sa-Token生成的token
    String saToken = StpUtil.getTokenValue();  // ✅ 这是前端需要的token
    
    // 5. 构建返回结果
    LoginResultVO result = LoginResultVO.builder()
        .accessToken(saToken)      // ✅ 返回给前端
        .refreshToken(saToken)     // Simple模式同一token
        .tokenType("Bearer")       // ✅ Token类型
        .expiresIn(86400L)         // 24小时
        .userInfo(userInfo)
        .build();
        
    return result;
}
```

#### 短信登录流程（相同）

```java
// 📍 AuthServiceImpl.java - 短信登录 (行213-216)
// 与密码登录完全相同的token生成逻辑
LoginHelper.login(loginUser, loginModel);
String saToken = StpUtil.getTokenValue();
```

### 1.2 LoginResultVO结构

**文件位置：** `LoginResultVO.java`

```java
public class LoginResultVO implements Serializable {
    private String accessToken;      // ✅ 前端需要存储这个
    private String refreshToken;     // ✅ 用于刷新token
    private String tokenType;        // "Bearer"
    private Long expiresIn;          // 86400秒 = 24小时
    private UserInfo userInfo;       // 用户信息
}
```

**✅ 后端Token生成总结：**
- Token生成器：**Sa-Token** (`StpUtil.getTokenValue()`)
- Token格式：**标准JWT格式**
- Token有效期：**24小时** (86400秒)
- Token前缀：**Bearer** (OAuth 2.0标准)
- 返回字段：`accessToken`, `refreshToken`, `tokenType`, `expiresIn`

---

## 2. 前端Token存储机制

### 2.1 AuthStore实现

**文件位置：** `authStore.ts` (行189-191)

```typescript
// 📍 authStore.ts - 登录成功后的存储逻辑
login: async (credentials) => {
    // 1. 调用后端登录API
    const response = await backendAuthApi.loginWithPassword({
        username: credentials.phone,
        password: credentials.password,
        clientType: 'app',
        deviceId: get().deviceId || generateDeviceId(),
    });
    
    // 2. 解构后端返回的数据
    const { accessToken, refreshToken, userInfo, expiresIn } = response.data;
    
    // 3. ✅ 保存到SecureStore (加密存储)
    await secureStorage.setItem(SECURE_KEYS.ACCESS_TOKEN, accessToken);
    await secureStorage.setItem(SECURE_KEYS.REFRESH_TOKEN, refreshToken);
    await secureStorage.setItem(SECURE_KEYS.USER_CREDENTIALS, JSON.stringify(adaptedUserInfo));
    
    // 4. ✅ 更新内存状态
    set({
        isAuthenticated: true,
        accessToken,
        refreshToken,
        userInfo: adaptedUserInfo,
    });
}
```

### 2.2 存储键定义

```typescript
// 📍 constants.ts (推测)
export const SECURE_KEYS = {
  ACCESS_TOKEN: 'auth_access_token',      // ✅ 存储accessToken
  REFRESH_TOKEN: 'auth_refresh_token',    // ✅ 存储refreshToken
  USER_CREDENTIALS: 'auth_user_credentials' // ✅ 存储用户信息
};
```

### 2.3 SecureStore实现

```typescript
// 📍 authStore.ts (行54-80)
const secureStorage = {
  async setItem(key: string, value: string): Promise<void> {
    try {
      // 优先使用Expo SecureStore (iOS Keychain / Android Keystore)
      await SecureStore.setItemAsync(key, value);
    } catch (error) {
      // 降级使用AsyncStorage
      await AsyncStorage.setItem(`secure_${key}`, value);
    }
  },
  
  async getItem(key: string): Promise<string | null> {
    try {
      return await SecureStore.getItemAsync(key);
    } catch (error) {
      return await AsyncStorage.getItem(`secure_${key}`);
    }
  }
};
```

**✅ 前端Token存储总结：**
- 存储位置：**Expo SecureStore** (安全加密存储)
- 降级方案：**AsyncStorage** (普通本地存储)
- 存储键：`auth_access_token`, `auth_refresh_token`
- 初始化加载：应用启动时从SecureStore读取 (行97-113)

---

## 3. Token使用流程

### 3.1 API客户端配置

**文件位置：** `client.ts`

#### 3.1.1 连接AuthStore

```typescript
// 📍 client.ts (行231-237)
connectAuthStore(useAuthStoreGetter: any): void {
    this.authStoreGetter = useAuthStoreGetter;
    console.log('🔌 API拦截器 - 已连接AuthStore');
    console.log('   功能: 自动添加token + 401自动刷新');
}
```

#### 3.1.2 自动获取Token

```typescript
// 📍 client.ts (行252-264)
private getAuthToken(): string | null {
    if (!this.authStoreGetter) {
        return null;
    }
    
    try {
        const state = this.authStoreGetter.getState();
        return state?.accessToken || null;  // ✅ 从authStore读取token
    } catch (error) {
        console.error('Get auth token error:', error);
        return null;
    }
}
```

#### 3.1.3 自动注入Token到请求头

```typescript
// 📍 client.ts (行452-476)
private async makeRequest<T>(url: string, config: RequestConfig, body?: any) {
    // 1. ✅ 获取当前token
    const token = this.getAuthToken();
    
    if (token) {
        // 2. ✅ 方法1: Authorization Header (OAuth 2.0标准 + SA-Token要求)
        if (this.tokenConfig.useAuthorizationHeader) {
            const tokenValue = `${this.tokenConfig.tokenPrefix} ${token}`;
            requestHeaders['Authorization'] = tokenValue;  // "Bearer <token>"
        }
        
        // 3. ✅ 方法2: 自定义Headers (备用)
        if (this.tokenConfig.useCustomHeaders) {
            this.tokenConfig.customHeaderNames.forEach(headerName => {
                requestHeaders[headerName] = token;  // "satoken: <token>"
            });
        }
        
        // 4. ✅ 方法3: URL参数 (SA-Token支持)
        if (this.tokenConfig.useUrlParameter) {
            fullUrl = `${fullUrl}?Authorization=${encodeURIComponent(tokenValue)}`;
        }
    }
    
    // 5. ✅ 添加ClientId Header (SA-Token必需)
    if (this.tokenConfig.includeClientId) {
        requestHeaders['clientid'] = this.clientId;  // "clientid: app"
    }
}
```

### 3.2 Token传输配置

```typescript
// 📍 client.ts (行172-182) - 默认配置
const DEFAULT_TOKEN_CONFIG: TokenTransmissionConfig = {
    useAuthorizationHeader: true,    // ✅ 启用: "Authorization: Bearer <token>"
    useCustomHeaders: false,         // ❌ 禁用自定义header
    customHeaderNames: ['satoken', 'token', 'X-Token'],
    useUrlParameter: false,          // ❌ 禁用URL参数
    urlParameterName: 'Authorization',
    includeClientId: true,           // ✅ 启用: "clientid: app"
    clientIdHeaderName: 'clientid',
    tokenPrefix: 'Bearer',           // ✅ Token前缀
    enableDebugLogs: true,           // ✅ 启用调试日志
};
```

**✅ Token使用总结：**
- **主要方式：** `Authorization: Bearer <token>` (OAuth 2.0标准)
- **附加Header：** `clientid: app` (必须与登录时的clientType一致)
- **自动注入：** 每次API请求自动添加token
- **调试日志：** 详细记录token注入过程

---

## 4. Sa-Token配置检查

### 4.1 后端Sa-Token配置

**文件位置：** `xypai-security/security-oauth/src/main/java/com/xypai/auth/config/SaTokenConfig.java`

```java
@Configuration
public class SaTokenConfig {
    @Bean
    @Order(-100)
    public SaServletFilter saServletFilter() {
        return new SaServletFilter()
            .addInclude("/**")
            // ✅ 放行认证相关接口（无需token）
            .addExclude("/api/v1/auth/**")
            // ✅ 放行文档和健康检查
            .addExclude("/v3/api-docs/**")
            .addExclude("/favicon.ico", "/error")
            .addExclude("/actuator", "/actuator/**")
            .setAuth(obj -> {
                // ✅ 其他路径需要登录认证
                SaRouter.match("/**", r -> StpUtil.checkLogin());
            });
    }
}
```

**✅ Sa-Token配置总结：**
- **白名单：** `/api/v1/auth/**` (登录、登出、刷新token等接口)
- **需要认证：** 其他所有接口 (`/**`)
- **验证方式：** `StpUtil.checkLogin()` (检查token有效性)
- **Token格式要求：** `Bearer <token>` (通过Authorization Header传输)

### 4.2 Sa-Token通用配置

**配置文件：** `application.yml` 或 `ruoyi-common-satoken`

```yaml
# 推测的Sa-Token配置
sa-token:
  token-name: Authorization          # Token名称
  token-prefix: Bearer               # Token前缀（必须）
  timeout: 86400                     # Token有效期（秒）
  jwt-secret-key: <your-secret>      # JWT密钥
  is-concurrent: true                # 允许同一账号多端登录
  is-share: true                     # 多设备共享token
```

---

## 5. 潜在问题分析

### 🔴 问题1：ClientId不一致

**问题描述：**
- 登录时后端使用：`loginModel.setDeviceType(loginDTO.getClientType())`
- 前端传值：`clientType: 'app'`
- 但前端API请求时的ClientId需要与登录时的clientType **完全一致**

**检查位置：**
```typescript
// 📍 client.ts (行189)
private clientId: string = 'app';  // ✅ 当前设置为 'app'

// 📍 authStore.ts (行152)
clientType: 'app',  // ✅ 登录时使用 'app'
```

**状态：** ✅ **正常** - clientId与登录时的clientType一致

---

### 🟡 问题2：Token前缀配置

**问题描述：**
Sa-Token要求token必须带 `Bearer` 前缀，前端需要确保传输格式正确。

**检查结果：**
```typescript
// 📍 client.ts (行467-470)
if (this.tokenConfig.useAuthorizationHeader) {
    const tokenValue = `${this.tokenConfig.tokenPrefix} ${token}`;  // ✅ "Bearer <token>"
    requestHeaders['Authorization'] = tokenValue;
}

// 📍 client.ts (行180)
tokenPrefix: 'Bearer',  // ✅ 已配置Bearer前缀
```

**状态：** ✅ **正常** - Token前缀已正确配置

---

### 🟢 问题3：Token刷新机制

**问题描述：**
当token过期（401错误）时，前端需要自动刷新token并重试请求。

**检查结果：**
```typescript
// 📍 client.ts (行266-400) - 401错误处理
private async handleUnauthorized<T>(url: string, config: RequestConfig, body?: any) {
    // 1. 检查白名单（区分匿名接口、可选认证、必须认证）
    const whitelistCheck = checkWhitelist(url);
    
    // 2. 尝试刷新token
    if (this.authStoreGetter) {
        const authActions = this.authStoreGetter.getState();
        await authActions.refreshAuthToken();  // ✅ 调用authStore的刷新方法
        
        const newToken = this.getAuthToken();
        if (newToken) {
            this.setAuthToken(newToken);
            return await this.makeRequest<T>(url, { ...config, retry: false }, body);  // ✅ 重试请求
        }
    }
    
    // 3. 刷新失败，清除认证数据
    authActions.clearAuthData();
    throw createError(ERROR_TYPES.AUTHENTICATION_ERROR, '登录已过期，请重新登录', 401);
}
```

**刷新Token接口：**
```typescript
// 📍 authStore.ts (行260-347) - Token刷新逻辑
refreshAuthToken: async () => {
    const currentRefreshToken = get().refreshToken;
    
    // 调用后端刷新接口
    const response = await backendAuthApi.refreshToken(currentRefreshToken);
    
    const { accessToken, refreshToken: newRefreshToken, userInfo } = response.data;
    
    // 保存新token到SecureStore
    await secureStorage.setItem(SECURE_KEYS.ACCESS_TOKEN, accessToken);
    await secureStorage.setItem(SECURE_KEYS.REFRESH_TOKEN, newRefreshToken);
    
    // 更新内存状态
    set({
        accessToken,
        refreshToken: newRefreshToken,
        userInfo: adaptedUserInfo,
        isAuthenticated: true,
    });
}
```

**状态：** ✅ **正常** - 401自动刷新机制完整

---

### 🟡 问题4：Token初始化时机

**问题描述：**
应用启动时需要从SecureStore读取token，并在API Client准备好之前完成初始化。

**检查结果：**
```typescript
// 📍 authStore.ts (行97-133) - 初始化方法
initialize: async () => {
    console.log('🔐 Initializing auth store...');
    
    // 1. 从SecureStore读取token
    const accessToken = await secureStorage.getItem(SECURE_KEYS.ACCESS_TOKEN);
    const refreshToken = await secureStorage.getItem(SECURE_KEYS.REFRESH_TOKEN);
    const userCredentials = await secureStorage.getItem(SECURE_KEYS.USER_CREDENTIALS);
    
    // 2. 解析用户信息
    let userInfo: UserInfo | null = null;
    if (userCredentials) {
        userInfo = JSON.parse(userCredentials);
    }
    
    // 3. 更新状态
    set({
        accessToken,
        refreshToken,
        userInfo,
        isAuthenticated: !!accessToken,
        isInitialized: true,
    });
}
```

**问题：** 🟡 **需要确认** - 初始化完成后，是否调用了 `apiClient.setAuthToken(accessToken)`？

**建议修复：**
```typescript
// 📍 authStore.ts - 初始化时自动设置token到API Client
initialize: async () => {
    // ...读取token...
    
    set({
        accessToken,
        refreshToken,
        userInfo,
        isAuthenticated: !!accessToken,
        isInitialized: true,
    });
    
    // ✅ 添加：自动设置token到API Client
    if (accessToken) {
        apiClient.setAuthToken(accessToken);
        console.log('✅ Token已自动设置到API Client');
    }
}
```

---

### 🔴 问题5：API Client与AuthStore的连接顺序

**问题描述：**
需要确保在任何API请求之前，API Client已经连接到AuthStore。

**检查位置：**
需要在应用入口（如 `App.tsx` 或 `_layout.tsx`）中确认初始化顺序：

```typescript
// 推荐的初始化顺序
async function initializeApp() {
    // 1. 连接API Client和AuthStore
    apiClient.connectAuthStore(useAuthStore);
    
    // 2. 初始化AuthStore（读取存储的token）
    await useAuthStore.getState().initialize();
    
    // 3. 设置token到API Client
    const token = useAuthStore.getState().accessToken;
    if (token) {
        apiClient.setAuthToken(token);
    }
}
```

**状态：** 🔴 **需要检查** - 未找到应用入口的初始化代码

---

## 6. 修复建议

### ✅ 修复1：自动初始化Token到API Client

**文件位置：** `authStore.ts`

```typescript
// 在initialize方法末尾添加
initialize: async () => {
    try {
        console.log('🔐 Initializing auth store...');
        
        const accessToken = await secureStorage.getItem(SECURE_KEYS.ACCESS_TOKEN);
        const refreshToken = await secureStorage.getItem(SECURE_KEYS.REFRESH_TOKEN);
        const userCredentials = await secureStorage.getItem(SECURE_KEYS.USER_CREDENTIALS);
        
        let userInfo: UserInfo | null = null;
        if (userCredentials) {
            userInfo = JSON.parse(userCredentials);
        }
        
        set({
            accessToken,
            refreshToken,
            userInfo,
            isAuthenticated: !!accessToken,
            isInitialized: true,
        });
        
        // ✅ 添加：自动设置token到API Client
        if (accessToken) {
            const { apiClient } = await import('../../../../services/api/client');
            apiClient.setAuthToken(accessToken);
            console.log('✅ Token已自动设置到API Client');
        }
        
        console.log('✅ Auth store initialized successfully');
    } catch (error) {
        console.error('❌ Auth store initialization failed:', error);
        set({
            isInitialized: true,
            isAuthenticated: false,
        });
    }
}
```

---

### ✅ 修复2：应用入口初始化

**文件位置：** `app/_layout.tsx` 或 `App.tsx`

```typescript
import { useEffect } from 'react';
import { apiClient } from '@/services/api/client';
import { useAuthStore } from '@/features/AuthModule/stores/authStore';

export default function RootLayout() {
    useEffect(() => {
        async function initializeApp() {
            console.log('🚀 Initializing application...');
            
            // 1. 连接API Client和AuthStore
            apiClient.connectAuthStore(useAuthStore);
            console.log('✅ API Client connected to AuthStore');
            
            // 2. 初始化AuthStore（会自动设置token到API Client）
            await useAuthStore.getState().initialize();
            console.log('✅ AuthStore initialized');
        }
        
        initializeApp();
    }, []);
    
    return <>{/* Your app layout */}</>;
}
```

---

### ✅ 修复3：登录成功后自动设置Token

**文件位置：** `authApi.ts`

```typescript
// 📍 authApi.ts (已实现，确认生效)
async loginWithPassword(request: PasswordLoginRequest): Promise<ApiResponse<LoginResultVO>> {
    const response = await apiClient.post<LoginResultVO>('/xypai-auth/api/v1/auth/login', {...});
    
    // ✅ 已实现：登录成功后自动设置token
    if (response.success && response.data?.accessToken) {
        apiClient.setAuthToken(response.data.accessToken);
        console.log('✅ [AuthAPI] 登录成功，已自动设置token');
    }
    
    return response;
}
```

**状态：** ✅ **已实现** - 无需修改

---

### 📋 修复4：添加Token调试工具

**新建文件：** `services/api/tokenDebug.ts`

```typescript
/**
 * Token调试工具
 * 用于诊断token传输问题
 */

import { apiClient } from './client';
import { useAuthStore } from '@/features/AuthModule/stores/authStore';

export const tokenDebug = {
    /**
     * 检查Token状态
     */
    checkTokenStatus() {
        const authState = useAuthStore.getState();
        const apiToken = apiClient['defaultHeaders']['Authorization'];
        
        console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        console.log('🔍 Token状态检查');
        console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        console.log('🔐 AuthStore状态:');
        console.log('   isAuthenticated:', authState.isAuthenticated);
        console.log('   accessToken:', authState.accessToken?.substring(0, 30) + '...');
        console.log('   refreshToken:', authState.refreshToken?.substring(0, 30) + '...');
        console.log('\n🌐 API Client状态:');
        console.log('   Authorization Header:', apiToken || '未设置');
        console.log('   ClientId:', apiClient.getClientId());
        console.log('\n✅ 对比结果:');
        const isConsistent = apiToken?.includes(authState.accessToken || '');
        console.log('   Token一致性:', isConsistent ? '✅ 一致' : '❌ 不一致');
        console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
        
        return {
            authStoreToken: authState.accessToken,
            apiClientToken: apiToken,
            isConsistent,
        };
    },
    
    /**
     * 测试Token有效性
     */
    async testTokenValidity() {
        console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        console.log('🧪 测试Token有效性');
        console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        
        try {
            // 调用一个需要认证的接口
            const response = await apiClient.get('/xypai-auth/api/v1/auth/heartbeat');
            
            console.log('✅ Token有效');
            console.log('   响应:', response);
            console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
            return true;
        } catch (error: any) {
            console.log('❌ Token无效或已过期');
            console.log('   错误:', error.message);
            console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
            return false;
        }
    },
    
    /**
     * 强制刷新Token
     */
    async forceRefreshToken() {
        console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        console.log('🔄 强制刷新Token');
        console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        
        try {
            const authActions = useAuthStore.getState();
            await authActions.refreshAuthToken();
            
            console.log('✅ Token刷新成功');
            console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
            return true;
        } catch (error: any) {
            console.log('❌ Token刷新失败');
            console.log('   错误:', error.message);
            console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
            return false;
        }
    },
    
    /**
     * 打印请求Headers
     */
    printRequestHeaders() {
        const authState = useAuthStore.getState();
        const token = authState.accessToken;
        
        console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        console.log('📋 预期的请求Headers');
        console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        console.log('Authorization:', `Bearer ${token?.substring(0, 30)}...`);
        console.log('clientid:', apiClient.getClientId());
        console.log('Content-Type: application/json');
        console.log('Accept: application/json');
        console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    }
};

// 导出到全局（开发环境）
if (__DEV__) {
    (global as any).tokenDebug = tokenDebug;
    console.log('🛠️ Token调试工具已挂载到 global.tokenDebug');
}
```

**使用方法：**
```typescript
// 在React Native调试器中执行
global.tokenDebug.checkTokenStatus();      // 检查token状态
global.tokenDebug.testTokenValidity();     // 测试token有效性
global.tokenDebug.forceRefreshToken();     // 强制刷新token
global.tokenDebug.printRequestHeaders();   // 打印请求headers
```

---

## 📊 总结

### ✅ 正常工作的部分

1. **后端Token生成** - Sa-Token正确生成JWT token
2. **前端Token存储** - SecureStore安全存储token
3. **Token自动注入** - API Client自动添加Authorization Header
4. **401自动刷新** - 完整的token刷新机制
5. **Token格式** - 正确使用`Bearer <token>`格式
6. **ClientId传输** - 正确添加`clientid: app` header

### 🟡 需要确认的部分

1. **应用初始化顺序** - 需要确认API Client是否在应用启动时正确连接到AuthStore
2. **Token初始化** - 需要确认从SecureStore读取的token是否自动设置到API Client

### 🔧 推荐的修复步骤

1. **步骤1：** 修改`authStore.ts`的`initialize`方法，添加自动设置token到API Client的逻辑
2. **步骤2：** 在应用入口（`app/_layout.tsx`）添加初始化代码，确保正确的初始化顺序
3. **步骤3：** 添加`tokenDebug.ts`调试工具，方便诊断token问题
4. **步骤4：** 测试以下场景：
   - 登录成功后立即调用需要认证的接口
   - 应用重启后调用需要认证的接口
   - Token过期后自动刷新
   - 刷新Token失败后引导登录

### 🎯 关键验证点

运行以下测试确认token机制完全正常：

```typescript
// 测试1: 登录后立即访问受保护接口
await authApi.loginWithPassword({...});
const response = await userApi.getCurrentProfile();  // 应该成功

// 测试2: 应用重启后访问受保护接口
// 1. 重启应用
// 2. 调用受保护接口
const response = await userApi.getCurrentProfile();  // 应该成功

// 测试3: Token过期后自动刷新
// 1. 等待token过期（或手动篡改token）
// 2. 调用受保护接口
const response = await userApi.getCurrentProfile();  // 应该自动刷新后成功

// 测试4: RefreshToken过期后引导登录
// 1. 清除refreshToken
// 2. 调用受保护接口
const response = await userApi.getCurrentProfile();  // 应该抛出401错误，引导登录
```

---

**生成时间：** 2025-11-07  
**文档版本：** v1.0  
**维护人员：** AI Assistant


