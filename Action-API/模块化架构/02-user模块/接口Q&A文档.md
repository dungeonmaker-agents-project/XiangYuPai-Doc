# 02-user模块 - 接口Q&A文档

> **版本**: 1.0.0
> **创建时间**: 2025-11-14
> **适用范围**: 前端开发、后端开发、接口对接
> **维护状态**: 持续更新

---

## 📋 目录

1. [配置相关](#一配置相关)
2. [API路径相关](#二api路径相关)
3. [数据格式相关](#三数据格式相关)
4. [业务逻辑相关](#四业务逻辑相关)
5. [错误处理相关](#五错误处理相关)
6. [性能优化相关](#六性能优化相关)
7. [RPC集成相关](#七rpc集成相关)
8. [前端对接相关](#八前端对接相关)

---

## 一、配置相关

### Q1: 服务端口号是8002还是9401？

**A**: 实际实现使用的是 **9401**

**详细说明**:
- 文档中标注的8002是早期规划
- 实际部署使用9401，避免与其他服务冲突
- 前端请求应使用: `http://localhost:9401` (开发环境)
- 生产环境通过网关访问: `http://gateway:8080/user/*`

**配置位置**:
```yaml
# xypai-user/src/main/resources/application.yml
server:
  port: 9401
```

**修复建议**: ✅ 已在实现中使用9401，文档需要更新

---

### Q2: 数据库名称是user_db还是xypai_user？

**A**: 实际使用 **xypai_user**

**详细说明**:
- `xypai_user` 符合项目命名规范
- 所有XiangYuPai项目数据库统一以 `xypai_` 开头
- DDL文件位置: `E:\...\RuoYi-Cloud-Plus\xypai-user\sql\xypai_user.sql`

**JDBC配置**:
```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/xypai_user?...
```

**修复建议**: ✅ 已在实现中使用xypai_user，文档需要更新

---

### Q3: Redis使用哪个database？

**A**: 使用 **database=1**

**详细说明**:
- database=0: 网关和公共服务
- database=1: xypai-user服务
- database=2: 测试环境专用

**配置**:
```yaml
spring:
  data:
    redis:
      database: 1
```

**缓存Key前缀**:
- 用户资料: `user:profile:{userId}`
- 用户统计: `user:stats:{userId}`
- 关注关系: `user:follow:{userId}:{targetUserId}`

---

## 二、API路径相关

### Q4: 为什么文档和实现的API路径不一致？

**A**: 实现采用了更清晰的模块化路径设计

**对比表**:

| 功能 | 文档路径 | 实现路径 | 建议 |
|------|----------|----------|------|
| 获取他人主页 | `/api/users/{userId}/profile` | `/api/user/profile/other/{userId}` | 添加别名路由 |
| 关注用户 | `/api/users/{userId}/follow` | `/api/user/relation/follow/{userId}` | 添加别名路由 |
| 粉丝列表 | `/api/users/fans` | `/api/user/relation/fans` | 添加别名路由 |
| 关注列表 | `/api/users/following` | `/api/user/relation/following` | 添加别名路由 |

**解决方案**:

**方案A - 添加路由别名** (推荐):
```java
// 在Controller中添加别名mapping
@GetMapping({"/api/user/relation/fans", "/api/users/fans"})
public TableDataInfo<UserRelationVo> getFansList(...) {
    // ...
}
```

**方案B - 前端统一使用实现路径**:
- 前端代码统一使用 `/api/user/*` 路径
- 更新前端API文档

---

### Q5: `/api/user/skill` 和 `/api/user/skills` 应该用单数还是复数？

**A**: 推荐使用 **复数** `/api/user/skills`

**理由**:
- RESTful规范推荐使用复数
- 与其他资源命名保持一致 (`/users`, `/moments`, `/orders`)
- 语义更清晰(表示技能集合)

**建议修改**:
```java
// 修改所有SkillController的@RequestMapping
@RequestMapping("/api/user/skills")  // 改为复数
public class SkillController {
    // ...
}
```

**影响范围**:
- 后端: SkillController路径
- 前端: 技能相关API调用路径
- 文档: API文档路径

---

### Q6: 是否需要统一创建线上/线下技能的接口？

**A**: **建议分离**，使用 `/api/user/skills/online` 和 `/api/user/skills/offline`

**当前实现**:
```java
POST /api/user/skill  // 统一endpoint，通过skillType区分
```

**文档期望**:
```
POST /api/user/skills/online   // 创建线上技能
POST /api/user/skills/offline  // 创建线下技能
```

**分离的优点**:
1. **参数验证更精确**
   - 线上技能必填: gameName, gameRank, serviceHours
   - 线下技能必填: serviceType, location, availableTimes

2. **API语义更清晰**
   - 前端明确知道调用哪个接口
   - 减少参数混淆的可能

3. **便于后期扩展**
   - 两种技能可以独立演化
   - 添加特定业务逻辑更方便

**修复代码示例**:
```java
@PostMapping("/online")
public R<Long> createOnlineSkill(@RequestBody @Validated OnlineSkillCreateDto dto) {
    return skillService.createOnlineSkill(userId, dto);
}

@PostMapping("/offline")
public R<Long> createOfflineSkill(@RequestBody @Validated OfflineSkillCreateDto dto) {
    return skillService.createOfflineSkill(userId, dto);
}
```

---

## 三、数据格式相关

### Q7: 用户性别字段应该用String还是Integer？

**A**: **后端存储String，RPC返回Integer**

**详细说明**:

**数据库存储** (users表):
```sql
gender VARCHAR(10) COMMENT 'male/female/other'
```

**API返回** (UserProfileVo):
```java
private String gender; // "male", "female", "other"
```

**RPC返回** (AppLoginUser):
```java
private Integer gender; // 0=未设置, 1=男, 2=女
```

**转换规则**:
```java
// UserService → AppLoginUser 转换
if ("male".equals(user.getGender())) {
    loginUser.setGender(1);
} else if ("female".equals(user.getGender())) {
    loginUser.setGender(2);
} else {
    loginUser.setGender(0);
}
```

**前端使用建议**:
```typescript
// 前端枚举
enum Gender {
  Male = "male",
  Female = "female",
  Other = "other"
}

// 显示转换
const genderMap = {
  male: "男",
  female: "女",
  other: "其他"
};
```

---

### Q8: 生日字段的格式是什么？

**A**: **后端LocalDate，前端ISO 8601字符串**

**数据库**:
```sql
birthday DATE  -- 例如: 2000-01-15
```

**Java实体**:
```java
private LocalDate birthday;
```

**JSON序列化**:
```json
{
  "birthday": "2000-01-15"  // YYYY-MM-DD格式
}
```

**前端解析**:
```typescript
// TypeScript
interface UserProfile {
  birthday?: string; // "2000-01-15"
}

// 显示年龄
const calculateAge = (birthday: string) => {
  const today = new Date();
  const birthDate = new Date(birthday);
  let age = today.getFullYear() - birthDate.getFullYear();
  const monthDiff = today.getMonth() - birthDate.getMonth();
  if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
    age--;
  }
  return age;
};
```

---

### Q9: UserStatsVo包含哪些字段？文档和实现不一致

**A**: **实现更完整**，文档需要更新

**文档定义** (不完整):
```typescript
{
  followingCount: number;
  fansCount: number;
  likesCount: number;
}
```

**实际实现** (完整):
```java
{
  followingCount: Integer;    // 关注数
  fansCount: Integer;         // 粉丝数
  likesCount: Integer;        // 获赞数
  momentsCount: Integer;      // 动态数
  postsCount: Integer;        // 帖子数
  collectionsCount: Integer;  // 收藏数
  skillsCount: Integer;       // 技能数
  ordersCount: Integer;       // 订单数
}
```

**使用建议**:
- 前端应使用完整字段定义
- 暂时用不到的字段可以不显示，但应该接收

---

## 四、业务逻辑相关

### Q10: 拉黑用户后会发生什么？

**A**: **双向隔离，互相取消关注**

**详细行为**:

1. **拉黑操作执行**:
   ```java
   blockUser(userId: 1, blockedUserId: 2)
   ```

2. **自动执行的操作**:
   - ✅ 创建黑名单记录 (`user_blacklist`)
   - ✅ User1取消关注User2 (如果已关注)
   - ✅ User2取消关注User1 (如果已关注)
   - ✅ 双方统计数更新

3. **后续限制**:
   - ❌ User1无法查看User2的主页/动态/技能
   - ❌ User2无法查看User1的主页/动态/技能
   - ❌ User1无法关注User2
   - ❌ User2无法关注User1
   - ✅ 但举报记录会保留(用于管理员审核)

**API响应**:
```json
// 被拉黑用户尝试访问
GET /api/users/{blockedUser}/profile
Response: 403 Forbidden
{
  "code": 403,
  "message": "User is blocked or has blocked you"
}
```

---

### Q11: 关注状态有哪几种？如何判断？

**A**: **三种状态: none, following, mutual**

**判断逻辑**:
```java
String getFollowStatus(Long userId, Long targetUserId) {
    boolean isFollowing = userRelationMapper.selectRelation(userId, targetUserId) != null;
    boolean isFollowedBy = userRelationMapper.selectRelation(targetUserId, userId) != null;

    if (isFollowing && isFollowedBy) {
        return "mutual";     // 互相关注
    } else if (isFollowing) {
        return "following";  // 单向关注
    } else {
        return "none";       // 未关注
    }
}
```

**数据库查询**:
```sql
-- 检查A是否关注B
SELECT * FROM user_relations
WHERE follower_id = A AND following_id = B AND deleted = 0;

-- 检查B是否关注A
SELECT * FROM user_relations
WHERE follower_id = B AND following_id = A AND deleted = 0;
```

**前端显示**:
```typescript
const followStatusMap = {
  none: { text: "关注", action: "follow" },
  following: { text: "已关注", action: "unfollow" },
  mutual: { text: "互相关注", action: "unfollow" }
};
```

---

### Q12: 隐私权限如何控制？

**A**: **三级权限 + 拉黑隔离**

**权限字段**:
```typescript
privacy: {
  canViewProfile: boolean;   // 能否查看基本资料
  canViewMoments: boolean;   // 能否查看动态
  canViewSkills: boolean;    // 能否查看技能
}
```

**权限规则**:

| 场景 | canViewProfile | canViewMoments | canViewSkills |
|------|----------------|----------------|---------------|
| 查看自己 | ✅ true | ✅ true | ✅ true |
| 查看普通用户 | ✅ true | ✅ true | ✅ true |
| 查看拉黑用户 | ❌ false | ❌ false | ❌ false |
| 被拉黑后查看 | ❌ false | ❌ false | ❌ false |

**实现代码**:
```java
public boolean checkPrivacy(Long userId, Long targetUserId) {
    // 检查是否被拉黑
    boolean isBlocked = userBlacklistMapper.hasBlacklist(userId, targetUserId);
    return !isBlocked;
}
```

**前端处理**:
```typescript
if (!privacy.canViewProfile) {
  showToast("无法查看该用户信息");
  router.back();
}

if (!privacy.canViewMoments) {
  hideTab("动态");
}
```

---

### Q13: 技能上架/下架的逻辑是什么？

**A**: **isOnline字段控制，仅上架技能对外展示**

**数据库字段**:
```sql
is_online BOOLEAN DEFAULT FALSE COMMENT '是否上架'
```

**业务规则**:

1. **创建技能**:
   - 默认 `isOnline = false` (下架状态)
   - 需要手动上架才能被用户看到

2. **上架条件** (建议添加):
   - ✅ 技能名称、描述已填写
   - ✅ 至少1张展示图片
   - ✅ 价格已设置
   - ✅ 线下技能: 可用时间已设置

3. **API接口**:
   ```java
   PUT /api/user/skill/{skillId}/toggle?isOnline=true  // 上架
   PUT /api/user/skill/{skillId}/toggle?isOnline=false // 下架
   ```

4. **查询过滤**:
   ```sql
   -- 用户查看自己的技能(包含下架)
   SELECT * FROM skills WHERE user_id = ? AND deleted = 0;

   -- 其他用户查看(仅上架)
   SELECT * FROM skills WHERE user_id = ? AND is_online = 1 AND deleted = 0;
   ```

---

## 五、错误处理相关

### Q14: 常见的错误码有哪些？

**A**: 标准错误码定义

| 错误码 | 含义 | 常见场景 | 前端处理 |
|--------|------|----------|----------|
| 200 | 成功 | 所有成功请求 | 正常处理 |
| 400 | 参数错误 | 验证失败、参数缺失 | 显示错误提示 |
| 401 | 未认证 | Token缺失/过期 | 跳转登录页 |
| 403 | 无权限 | 被拉黑、非所有者操作 | 显示无权限提示 |
| 404 | 资源不存在 | 用户/技能不存在 | 显示资源不存在 |
| 500 | 服务器错误 | 系统异常 | 显示通用错误 |

**错误响应格式**:
```json
{
  "code": 400,
  "message": "昵称长度为2-20字符",
  "data": null,
  "timestamp": 1700000000000
}
```

**前端统一处理**:
```typescript
axios.interceptors.response.use(
  response => response.data,
  error => {
    const { code, message } = error.response.data;

    switch (code) {
      case 401:
        router.push('/login');
        break;
      case 403:
        showToast('无权限操作');
        break;
      case 404:
        showToast('资源不存在');
        break;
      default:
        showToast(message || '操作失败');
    }

    return Promise.reject(error);
  }
);
```

---

### Q15: 如何处理并发更新冲突？

**A**: **使用乐观锁(Version字段)**

**数据库设计**:
```sql
ALTER TABLE users ADD COLUMN version INT NOT NULL DEFAULT 0;
```

**MyBatis Plus自动处理**:
```java
@Version
@TableField("version")
private Integer version;
```

**更新流程**:
```java
// 1. 查询时获取version
User user = userMapper.selectById(1L);  // version=5

// 2. 更新时检查version
user.setNickname("NewName");
int rows = userMapper.updateById(user);
// SQL: UPDATE users SET nickname=?, version=6
//      WHERE user_id=1 AND version=5

// 3. 判断更新结果
if (rows == 0) {
    throw new ServiceException("数据已被其他用户修改，请刷新后重试");
}
```

**前端处理**:
```typescript
try {
  await updateNickname({ nickname: "NewName" });
} catch (error) {
  if (error.message.includes("数据已被其他用户修改")) {
    showConfirm("数据已更新，是否刷新？", () => {
      fetchUserProfile();
    });
  }
}
```

---

## 六、性能优化相关

### Q16: Redis缓存策略是什么？

**A**: **Cache-Aside模式 + TTL过期**

**缓存Key设计**:
```
user:profile:{userId}           # TTL: 30分钟
user:stats:{userId}             # TTL: 30分钟
user:follow:{userId}:{targetId} # TTL: 10分钟
skills:user:{userId}            # TTL: 10分钟
```

**读取流程**:
```java
public R<UserProfileVo> getUserProfile(Long userId) {
    String cacheKey = "user:profile:" + userId;

    // 1. 尝试从缓存读取
    UserProfileVo cached = redisUtils.getCacheObject(cacheKey);
    if (cached != null) {
        return R.ok(cached);  // 缓存命中
    }

    // 2. 缓存未命中，查询数据库
    User user = userMapper.selectById(userId);
    UserProfileVo vo = buildUserProfileVo(user);

    // 3. 写入缓存
    redisUtils.setCacheObject(cacheKey, vo, Duration.ofMinutes(30));

    return R.ok(vo);
}
```

**更新流程**:
```java
public R<Void> updateNickname(Long userId, UpdateNicknameDto dto) {
    // 1. 更新数据库
    User user = User.builder()
        .userId(userId)
        .nickname(dto.getNickname())
        .build();
    userMapper.updateById(user);

    // 2. 删除缓存(让下次读取时重新加载)
    redisUtils.deleteObject("user:profile:" + userId);

    return R.ok();
}
```

**为什么不立即更新缓存？**
- 避免缓存和数据库数据不一致
- 避免复杂的缓存构建逻辑
- 大部分用户不会立即再次查询

---

### Q17: 分页查询如何优化？

**A**: **使用MyBatis Plus分页插件 + 索引优化**

**分页配置**:
```java
@Bean
public MybatisPlusInterceptor mybatisPlusInterceptor() {
    MybatisPlusInterceptor interceptor = new MybatisPlusInterceptor();
    interceptor.addInnerInterceptor(new PaginationInnerInterceptor(DbType.MYSQL));
    return interceptor;
}
```

**分页查询**:
```java
public TableDataInfo<SkillVo> getMySkills(Long userId, PageQuery pageQuery) {
    // 创建分页对象
    Page<Skill> page = new Page<>(pageQuery.getPageNum(), pageQuery.getPageSize());

    // 构建查询条件
    LambdaQueryWrapper<Skill> wrapper = new LambdaQueryWrapper<>();
    wrapper.eq(Skill::getUserId, userId)
           .orderByDesc(Skill::getCreatedAt);

    // 执行分页查询
    Page<Skill> skillPage = skillMapper.selectPage(page, wrapper);

    // 转换为VO
    List<SkillVo> voList = skillPage.getRecords().stream()
        .map(this::buildSkillVo)
        .collect(Collectors.toList());

    return TableDataInfo.build(voList, skillPage.getTotal());
}
```

**SQL优化**:
```sql
-- 确保有索引
CREATE INDEX idx_user_id_created ON skills(user_id, created_at DESC);

-- 分页查询
SELECT * FROM skills
WHERE user_id = ?
ORDER BY created_at DESC
LIMIT 10 OFFSET 20;
```

**性能建议**:
- 页大小限制: 10-50条
- 避免深度分页 (offset > 10000)
- 使用游标分页替代offset(未来优化)

---

## 七、RPC集成相关

### Q18: xypai-auth如何调用UserService的RPC接口？

**A**: **通过Dubbo @DubboReference注入**

**步骤1: Auth服务添加依赖**:
```xml
<!-- xypai-auth/pom.xml -->
<dependency>
    <groupId>org.dromara</groupId>
    <artifactId>xypai-api-appuser</artifactId>
    <version>${revision}</version>
</dependency>
```

**步骤2: 注入RPC接口**:
```java
// xypai-auth服务中
@Service
public class AuthServiceImpl {

    @DubboReference
    private RemoteAppUserService remoteAppUserService;

    public R<LoginVo> smsLogin(String mobile, String code) {
        // 1. 验证短信验证码
        validateSmsCode(mobile, code);

        // 2. 注册或获取用户 (RPC调用)
        AppLoginUser user = remoteAppUserService.registerOrGetByMobile(mobile, "+86");

        // 3. 生成Token
        String token = StpUtil.createLoginSession(user.getUserId());

        // 4. 返回登录结果
        return R.ok(new LoginVo(token, user.getIsNewUser()));
    }
}
```

**步骤3: Nacos配置**:
```yaml
# xypai-auth的bootstrap.yml
dubbo:
  registry:
    address: nacos://localhost:8848
```

**调用链**:
```
xypai-auth (Consumer)
  → Nacos (服务发现)
    → xypai-user (Provider)
      → RemoteAppUserServiceImpl.registerOrGetByMobile()
        → UserService.createUser()
```

---

### Q19: RPC超时如何处理？

**A**: **配置超时时间 + 重试策略**

**Provider配置** (xypai-user):
```yaml
dubbo:
  provider:
    timeout: 10000  # 10秒超时
    retries: 0      # 不重试(避免重复创建)
```

**Consumer配置** (xypai-auth):
```yaml
dubbo:
  consumer:
    timeout: 10000
    retries: 0
    check: false    # 启动时不检查provider
```

**自定义超时**:
```java
@DubboReference(timeout = 5000, retries = 0)
private RemoteAppUserService remoteAppUserService;
```

**异常处理**:
```java
try {
    AppLoginUser user = remoteAppUserService.getUserByMobile(mobile, code);
} catch (DubboTimeoutException e) {
    log.error("RPC调用超时: {}", e.getMessage());
    return R.fail("用户服务繁忙，请稍后重试");
} catch (UserException e) {
    return R.fail(e.getMessage());
}
```

---

## 八、前端对接相关

### Q20: 前端如何携带Token？

**A**: **通过Authorization请求头**

**Axios配置**:
```typescript
// src/utils/request.ts
import axios from 'axios';

const request = axios.create({
  baseURL: 'http://localhost:9401',
  timeout: 10000
});

// 请求拦截器
request.interceptors.request.use(
  config => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers['Authorization'] = `Bearer ${token}`;
    }
    return config;
  },
  error => Promise.reject(error)
);

export default request;
```

**API调用**:
```typescript
// src/api/user.ts
import request from '@/utils/request';

export const getUserProfile = () => {
  return request.get('/api/user/profile/header');
};

export const updateNickname = (nickname: string) => {
  return request.put('/api/user/profile/nickname', { nickname });
};
```

---

### Q21: 如何处理实时保存的11个字段更新？

**A**: **失去焦点时触发保存 + 乐观更新**

**前端实现**:
```vue
<template>
  <van-field
    v-model="profile.nickname"
    label="昵称"
    placeholder="请输入昵称"
    @blur="saveNickname"
  >
    <template #right-icon>
      <van-loading v-if="saving.nickname" size="16" />
      <van-icon v-else-if="saveStatus.nickname === 'success'" name="success" color="#07c160" />
      <van-icon v-else-if="saveStatus.nickname === 'error'" name="fail" color="#ee0a24" />
    </template>
  </van-field>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue';
import { updateNickname } from '@/api/user';

const profile = reactive({
  nickname: 'TestUser',
  gender: 'male',
  // ...
});

const saving = reactive({
  nickname: false,
  gender: false,
  // ...
});

const saveStatus = reactive({
  nickname: '',
  gender: '',
  // ...
});

const saveNickname = async () => {
  saving.nickname = true;
  saveStatus.nickname = '';

  try {
    await updateNickname(profile.nickname);
    saveStatus.nickname = 'success';
    setTimeout(() => {
      saveStatus.nickname = '';
    }, 2000);
  } catch (error) {
    saveStatus.nickname = 'error';
    showToast('保存失败');
  } finally {
    saving.nickname = false;
  }
};
</script>
```

**防抖优化**:
```typescript
import { debounce } from 'lodash-es';

const saveNickname = debounce(async () => {
  // 保存逻辑
}, 500);
```

---

### Q22: 分页加载如何实现？

**A**: **上拉加载 + Infinite Scroll**

**前端实现**:
```vue
<template>
  <van-list
    v-model:loading="loading"
    :finished="finished"
    finished-text="没有更多了"
    @load="onLoad"
  >
    <van-cell
      v-for="skill in skillList"
      :key="skill.skillId"
      :title="skill.skillName"
      :value="`¥${skill.price}/${skill.priceUnit}`"
    />
  </van-list>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { getMySkills } from '@/api/skill';

const skillList = ref([]);
const loading = ref(false);
const finished = ref(false);
const page = ref(1);

const onLoad = async () => {
  try {
    const res = await getMySkills({
      page: page.value,
      pageSize: 10
    });

    skillList.value = [...skillList.value, ...res.data.skills];
    loading.value = false;

    if (res.data.skills.length < 10 || !res.data.hasMore) {
      finished.value = true;
    } else {
      page.value++;
    }
  } catch (error) {
    loading.value = false;
    showToast('加载失败');
  }
};
</script>
```

---

### Q23: 如何实现附近技能搜索？

**A**: **获取定位 + 调用nearby接口**

**前端实现**:
```typescript
// 1. 获取用户定位
import { getCurrentPosition } from '@/utils/location';

const searchNearbySkills = async () => {
  try {
    // 获取当前位置
    const position = await getCurrentPosition();
    const { latitude, longitude } = position;

    // 调用附近技能API
    const res = await request.get('/api/user/skill/nearby', {
      params: {
        latitude,
        longitude,
        radiusMeters: 10000, // 10km
        page: 1,
        pageSize: 20
      }
    });

    skillList.value = res.data.skills;
  } catch (error) {
    if (error.code === 'PERMISSION_DENIED') {
      showToast('请授权位置信息');
    } else {
      showToast('搜索失败');
    }
  }
};
```

**定位工具**:
```typescript
// src/utils/location.ts
export const getCurrentPosition = (): Promise<{ latitude: number; longitude: number }> => {
  return new Promise((resolve, reject) => {
    if (!navigator.geolocation) {
      reject(new Error('浏览器不支持定位'));
      return;
    }

    navigator.geolocation.getCurrentPosition(
      position => {
        resolve({
          latitude: position.coords.latitude,
          longitude: position.coords.longitude
        });
      },
      error => {
        reject(error);
      },
      {
        enableHighAccuracy: true,
        timeout: 5000,
        maximumAge: 0
      }
    );
  });
};
```

---

## 九、补充说明

### Q24: 哪些功能暂未实现，计划何时完成？

**A**: **缺失功能清单及计划**

| 功能 | 状态 | 优先级 | 计划完成时间 |
|------|------|--------|-------------|
| `GET /api/skills/config` | ❌ 未实现 | P0 | 1天内 |
| `POST /api/skills/images/upload` | ❌ 未实现 | P0 | 1天内 |
| 拆分online/offline技能接口 | ❌ 未实现 | P1 | 2天内 |
| 添加API路由别名 | ❌ 未实现 | P1 | 1天内 |
| OSS文件上传实现 | ⚠️ TODO | P1 | 3天内 |
| 密码加密逻辑 | ⚠️ TODO | P1 | 2天内 |
| 支付密码功能 | ⚠️ TODO | P2 | 1周内 |

**修复计划**: 见《接口一致性验证报告》

---

### Q25: 有推荐的测试工具吗？

**A**: **测试工具推荐**

| 工具 | 用途 | 下载地址 |
|------|------|----------|
| Postman | API手动测试 | https://www.postman.com/ |
| JMeter | 性能压测 | https://jmeter.apache.org/ |
| Redis Commander | Redis可视化 | `npm i -g redis-commander` |
| Knife4j | API文档 | http://localhost:9401/doc.html |

**Postman Collection导出**: 可从Knife4j导出OpenAPI 3.0规范

---

## 十、联系方式

**遇到问题如何反馈？**

1. **技术问题**:
   - 查阅本文档Q&A
   - 查阅《测试计划文档》
   - 查阅《接口一致性验证报告》

2. **Bug反馈**:
   - GitHub Issues: (仓库地址)
   - 团队协作平台

3. **紧急问题**:
   - 联系后端负责人
   - 团队群组讨论

---

**文档维护**: Backend Team
**最后更新**: 2025-11-14
**版本**: 1.0.0
