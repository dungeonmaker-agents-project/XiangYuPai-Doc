# 01-首页Feed流页面

## 一、页面概述

### 页面信息
- **路由路径**: `/home` 或 `/`
- **页面名称**: 首页Feed流
- **用户角色**: 登录用户
- **页面类型**: Tab页面(线上/线下切换)

### 页面功能
首页Feed流是应用的主入口页面,展示推荐的用户内容流。用户可以:
1. 浏览线上和线下两种类型的用户动态
2. 通过Tab切换查看不同类型的内容
3. 上拉加载更多内容
4. 下拉刷新列表
5. 点击用户卡片进入详情页
6. 关注/取消关注用户
7. 通过顶部导航进入筛选、搜索、位置选择等功能

### 进入方式
- 应用启动后的默认页面
- 底部TabBar点击"首页"图标
- 从其他页面返回首页

---

## 二、页面UI结构

### 2.1 顶部导航栏
```
[位置] 南山区 ▼  |  [搜索图标]  |  [筛选图标]  |  [消息图标]
```

**UI组件:**
- **位置按钮**: 显示当前选中的区域,点击打开区域选择页面
- **搜索图标**: 点击打开搜索页面
- **筛选图标**: 点击打开筛选页面,有筛选条件时显示数量角标
- **消息图标**: 点击进入消息中心,有未读消息时显示红点

### 2.2 Tab切换栏
```
[ 线上 ] | [ 线下 ]
```

**交互:**
- 激活Tab: 紫色文字 + 底部紫色下划线
- 未激活Tab: 灰色文字
- 点击切换:清空列表 → 显示加载动画 → 加载新数据

### 2.3 快捷入口区
```
[王者荣耀] [英雄联盟] [和平精英] [原神] [探店] [K歌] [更多]
```

**UI组件:**
- 图标 + 文字的圆形按钮
- 横向滚动,可左右滑动查看更多
- 点击进入对应的技能服务列表页

### 2.4 主内容区 - 用户卡片列表

**线上模式卡片布局:**
```
+----------------------------------+
| [头像]  昵称 ♂ 19      距离3.2km |
|         [可线上][2元][技能标签]   |
|         描述文字...              |
|                   10 金币/单 →   |
+----------------------------------+
```

**线下模式卡片布局:**
```
+----------------------------------+
| [头像]  昵称 ♀ 22      距离1.5km |
|         [可线下][探店][认证]     |
|         描述文字...              |
|                         [关注]   |
+----------------------------------+
```

**卡片信息:**
- 左侧: 用户头像(圆形/正方形)
- 右侧:
  - 第一行: 昵称 + 性别/年龄 + 距离
  - 第二行: 标签(可线上/线下、价格、技能等)
  - 第三行: 描述文字(最多2行)
  - 第四行: 价格(线上)/关注按钮(线下)

### 2.5 底部加载状态
- **加载中**: 显示Loading动画
- **加载完成**: 显示"已经到底了~"
- **加载失败**: 显示"加载失败,点击重试"

---

## 三、接口列表

### 3.1 页面加载时调用

#### 1. 获取首页Feed流
**接口:** `GET /api/home/feed`

**调用时机:**
- 页面首次加载
- 切换Tab(线上/线下)
- 下拉刷新

**请求参数:**
```typescript
{
  type: 'online' | 'offline';  // Tab类型
  pageNum: number;              // 页码,从1开始
  pageSize: number;             // 每页数量,建议10
  cityCode?: string;            // 城市代码(从全局状态获取)
  districtCode?: string;        // 区域代码(从全局状态获取)
}
```

**响应数据:**
```typescript
{
  code: number;
  message: string;
  data: {
    total: number;
    hasMore: boolean;
    list: Array<{
      userId: number;
      avatar: string;
      nickname: string;
      age?: number;
      gender: 'male' | 'female';
      distance: number;          // km
      tags: Array<{
        text: string;
        type: 'feature' | 'price' | 'skill';
        color?: string;
      }>;
      description: string;
      price?: {                  // 仅线上模式
        amount: number;
        unit: string;
        displayText: string;
      };
      isOnline: boolean;
      skills?: string[];
    }>;
  }
}
```

**后续操作:**
- 成功: 渲染用户卡片列表
- 失败: 显示错误提示 + 重试按钮
- 无数据: 显示空状态页

---

### 3.2 用户操作触发

#### 2. 关注/取消关注用户
**接口:** `POST /api/user/follow`

**调用时机:**
- 点击用户卡片上的"关注"按钮
- 点击"已关注"按钮时显示确认对话框

**请求参数:**
```typescript
{
  targetUserId: number;         // 目标用户ID
  action: 'follow' | 'unfollow';  // 操作类型
}
```

**响应数据:**
```typescript
{
  code: number;
  message: string;
  data: {
    success: boolean;
    relationStatus: 'none' | 'following' | 'followed' | 'mutual';
  }
}
```

**后续操作:**
- 关注成功: 按钮文字改为"已关注",样式变灰
- 取消关注成功: 按钮文字改为"关注",样式变紫
- 互相关注: 按钮文字改为"互相关注",紫色填充
- 失败: Toast提示错误信息

**前端验证:**
- 需要登录状态,未登录跳转登录页
- 不能关注自己
- 防抖处理:2秒内不能重复操作

---

### 3.3 分页加载

#### 3. 上拉加载更多
**接口:** `GET /api/home/feed`

**调用时机:**
- 列表滚动到距离底部100px时触发

**请求参数:**
```typescript
{
  type: 'online' | 'offline';
  pageNum: number;              // 当前页码+1
  pageSize: number;
  cityCode?: string;
  districtCode?: string;
}
```

**后续操作:**
- 新数据追加到列表末尾
- 如果hasMore=false:显示"已经到底了~"
- 如果加载失败:显示"加载失败,点击重试"

---

## 四、数据流

### 4.1 初始加载流程
```
1. 页面mount
2. 从全局状态获取location信息(cityCode, districtCode)
3. 调用GET /api/home/feed (pageNum=1, type='online')
4. 显示Loading骨架屏
5. 收到响应 → 渲染用户卡片列表
6. 保存hasMore状态
```

### 4.2 Tab切换流程
```
1. 用户点击"线下"Tab
2. 更新激活Tab样式
3. 清空当前列表
4. 重置pageNum=1
5. 调用GET /api/home/feed (type='offline')
6. 显示Loading动画
7. 收到响应 → 渲染新列表
```

### 4.3 下拉刷新流程
```
1. 用户下拉列表
2. 显示刷新动画
3. 重置pageNum=1
4. 调用GET /api/home/feed
5. 收到响应 → 替换整个列表
6. 隐藏刷新动画
```

### 4.4 上拉加载流程
```
1. 监听列表滚动
2. 距离底部<100px时触发
3. 检查hasMore状态
4. 如果hasMore=true → pageNum+1 → 调用接口
5. 显示底部Loading
6. 收到响应 → 追加数据到列表
7. 更新hasMore状态
```

### 4.5 关注操作流程
```
1. 用户点击"关注"按钮
2. 检查登录状态
3. 防抖检查(2秒内禁止重复)
4. 调用POST /api/user/follow (action='follow')
5. 成功 → 更新按钮状态和文字
6. 失败 → Toast错误提示
```

---

## 五、状态管理

### 5.1 页面级状态 (useState/data)
```typescript
{
  currentTab: 'online' | 'offline';  // 当前激活Tab
  feedList: User[];                  // 用户列表数据
  pageNum: number;                   // 当前页码
  hasMore: boolean;                  // 是否有更多数据
  loading: boolean;                  // 是否加载中
  refreshing: boolean;               // 是否刷新中
  error: string | null;              // 错误信息
}
```

### 5.2 全局状态 (Store/Context)
```typescript
{
  location: {
    cityCode: string;
    cityName: string;
    districtCode: string;
    districtName: string;
  };
  userInfo: {
    userId: number;
    nickname: string;
    avatar: string;
  };
  filters: {
    age?: { min: number; max: number };
    gender?: string;
    // ... 筛选条件
  };
}
```

### 5.3 缓存策略
- **Feed列表**: 会话级缓存,退出页面清除
- **位置信息**: 本地缓存30天
- **筛选条件**: 会话级缓存,退出App清除
- **关注状态**: 实时更新,不缓存

---

## 六、路由参数

### 6.1 进入参数
```typescript
{
  // 通常无参数,从TabBar直接进入
  tab?: 'online' | 'offline';  // 可选:指定默认Tab
}
```

### 6.2 跳转目标

#### 点击用户卡片
```typescript
// 跳转到用户主页(未实现,待补充)
this.$router.push({
  path: '/user/profile',
  query: { userId: user.userId, from: 'home' }
});
```

#### 点击位置按钮
```typescript
// 跳转到区域选择页
this.$router.push({ path: '/location/district' });
```

#### 点击搜索图标
```typescript
// 跳转到搜索页
this.$router.push({ path: '/search' });
```

#### 点击筛选图标
```typescript
// 打开筛选页面
this.$router.push({
  path: '/filter',
  query: { type: this.currentTab }
});
```

#### 点击快捷入口(如"王者荣耀")
```typescript
// 跳转到技能服务列表页
this.$router.push({
  path: '/service/list',
  query: { skillType: '王者荣耀' }
});
```

---

## 七、错误处理

### 7.1 网络错误
```
显示: "网络异常,请稍后重试"
操作: 提供"重试"按钮,点击重新调用接口
```

### 7.2 数据为空
```
显示: "暂无推荐用户"
操作: 提供"刷新"按钮或"调整筛选条件"按钮
```

### 7.3 位置未选择
```
显示: "请先选择城市"
操作: 提供"选择城市"按钮,跳转到城市选择页
```

### 7.4 未登录
```
显示: "请先登录"
操作: 跳转到登录页
```

### 7.5 关注操作失败
```
显示: Toast提示"操作失败,请重试"
操作: 按钮状态保持原样,允许重试
```

---

## 八、测试要点

### 8.1 页面加载测试
- [ ] 首次进入页面,Feed流正常加载
- [ ] 线上Tab默认激活
- [ ] 用户卡片正确渲染(头像、昵称、标签、价格等)
- [ ] 距离显示正确
- [ ] 位置信息显示正确(顶部导航)

### 8.2 Tab切换测试
- [ ] 点击"线下"Tab,列表切换正常
- [ ] Tab激活状态样式正确
- [ ] 切换时清空列表并重新加载
- [ ] 线下模式显示关注按钮而非价格

### 8.3 分页加载测试
- [ ] 上拉加载触发正常
- [ ] 新数据追加到列表末尾
- [ ] 无更多数据时显示"已经到底了~"
- [ ] 加载失败时显示重试按钮

### 8.4 刷新测试
- [ ] 下拉刷新正常工作
- [ ] 刷新后列表更新
- [ ] 刷新动画正常显示和隐藏

### 8.5 关注功能测试
- [ ] 点击"关注"按钮,状态正确更新
- [ ] 点击"已关注"按钮,显示确认对话框
- [ ] 互相关注状态显示正确
- [ ] 未登录时跳转登录页
- [ ] 防抖处理生效

### 8.6 导航功能测试
- [ ] 点击位置按钮,跳转区域选择页
- [ ] 点击搜索图标,跳转搜索页
- [ ] 点击筛选图标,跳转筛选页
- [ ] 点击快捷入口,跳转对应服务列表

### 8.7 边界测试
- [ ] 位置未选择时的处理
- [ ] 网络异常时的错误提示
- [ ] 数据为空时的空状态显示
- [ ] 接口超时的处理

### 8.8 性能测试
- [ ] 列表滚动流畅,无卡顿
- [ ] 图片懒加载正常
- [ ] 长列表虚拟滚动(可选)

---

## 九、使用的后端服务

### HomeService
- `GET /api/home/feed` - 获取Feed流列表

### UserService
- `POST /api/user/follow` - 关注/取消关注用户

### LocationService
- 通过全局状态提供位置信息(cityCode, districtCode)

---

## 十、前端实现要点

### 组件结构
```
HomeFeeds/
├── index.vue                  // 页面主组件
├── components/
│   ├── TabBar.vue            // Tab切换栏
│   ├── QuickEntry.vue        // 快捷入口
│   ├── UserCard.vue          // 用户卡片(线上)
│   ├── UserCardOffline.vue   // 用户卡片(线下)
│   └── EmptyState.vue        // 空状态
└── hooks/
    ├── useFeeds.ts           // Feed数据管理
    ├── useFollow.ts          // 关注逻辑
    └── usePagination.ts      // 分页逻辑
```

### 关键逻辑
1. **分页加载**: 使用IntersectionObserver或scroll监听
2. **防抖**: 使用lodash.debounce或自定义debounce
3. **状态管理**: 使用Vuex/Pinia或React Context
4. **错误处理**: 统一的错误拦截和Toast提示
5. **图片优化**: 使用懒加载和CDN缩略图

---

## 十一、依赖的全局功能

1. **位置服务**: 提供cityCode和districtCode
2. **用户认证**: 提供userInfo和token
3. **路由导航**: 跳转到其他页面
4. **Toast提示**: 显示操作结果
5. **Loading组件**: 加载动画

---

**文档版本**: v1.0
**最后更新**: 2025-01-XX
**维护者**: 前端团队
