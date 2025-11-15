# ReportService 后端服务文档

## 服务概述

ReportService是通用举报审核服务,负责处理内容举报、用户举报、审核管理等功能。该服务为全平台提供统一的内容审核能力,被多个模块调用(内容、用户、聊天、交易等)。

**服务名称:** xypai-report
**服务端口:** 8008
**所属模块:** 06-common模块
**数据库:** xypai_common
**技术栈:** Node.js + TypeScript + Express + MySQL + Redis

---

## 服务架构

### 核心功能

1. **举报管理**
   - 接收举报请求
   - 验证举报合法性
   - 防止重复举报
   - 自动分类和优先级排序

2. **审核流程**
   - 待审核队列
   - 人工审核
   - 自动审核(敏感词/图像识别)
   - 审核结果通知

3. **处罚管理**
   - 内容下架
   - 用户禁言
   - 账号封禁
   - 处罚记录查询

4. **统计分析**
   - 举报数据统计
   - 违规类型分析
   - 审核效率监控

---

## API接口

### 1. 提交举报

**接口:** `POST /api/v1/report/submit`

**请求体:**
```typescript
{
  targetType: string;      // 举报对象类型: feed/comment/user/message/order
  targetId: string;        // 举报对象ID
  reasonType: string;      // 举报原因类型(从预定义列表选择)
  description?: string;    // 举报描述,0-200字符
  evidenceImages?: string[]; // 举报证据图片,最多3张
}
```

**举报原因类型(reasonType):**
- `harassment`: 骚扰辱骂
- `pornography`: 色情低俗
- `fraud`: 诈骗虚假
- `illegal`: 违法违规
- `false_info`: 虚假信息
- `underage`: 涉及未成年人
- `offensive`: 引战挑衅
- `other`: 其他原因

**业务逻辑:**

1. **验证用户登录状态**
   ```typescript
   const userId = req.user.id;
   if (!userId) {
     throw new Error('请先登录');
   }
   ```

2. **验证举报对象存在**
   ```typescript
   const validateTarget = async (targetType: string, targetId: string) => {
     switch (targetType) {
       case 'feed':
         const feed = await feedRepository.findOne({ where: { id: targetId } });
         if (!feed) throw new Error('动态不存在');
         break;
       case 'comment':
         const comment = await commentRepository.findOne({ where: { id: targetId } });
         if (!comment) throw new Error('评论不存在');
         break;
       case 'user':
         const user = await userRepository.findOne({ where: { id: targetId } });
         if (!user) throw new Error('用户不存在');
         break;
       default:
         throw new Error('不支持的举报类型');
     }
   };
   ```

3. **检查重复举报**
   ```typescript
   const checkDuplicateReport = async (
     userId: string,
     targetType: string,
     targetId: string
   ) => {
     const yesterday = new Date(Date.now() - 24 * 60 * 60 * 1000);

     const existingReport = await reportRepository.findOne({
       where: {
         userId,
         targetType,
         targetId,
         createdAt: MoreThan(yesterday)
       }
     });

     if (existingReport) {
       throw new Error('24小时内已举报过该内容');
     }
   };
   ```

4. **验证举报原因**
   ```typescript
   const validReasonTypes = [
     'harassment', 'pornography', 'fraud', 'illegal',
     'false_info', 'underage', 'offensive', 'other'
   ];

   if (!validReasonTypes.includes(reasonType)) {
     throw new Error('举报原因类型不正确');
   }
   ```

5. **创建举报记录**
   ```typescript
   const createReport = async (data: ReportData) => {
     const report = new Report();
     report.id = generateUUID();
     report.userId = data.userId;
     report.targetType = data.targetType;
     report.targetId = data.targetId;
     report.reasonType = data.reasonType;
     report.description = data.description;
     report.evidenceImages = data.evidenceImages;
     report.status = 'pending';
     report.priority = calculatePriority(data.reasonType);

     await reportRepository.save(report);

     return report;
   };
   ```

6. **计算优先级**
   ```typescript
   const calculatePriority = (reasonType: string): number => {
     const priorityMap = {
       'illegal': 1,        // 最高优先级
       'pornography': 1,
       'underage': 1,
       'fraud': 2,
       'harassment': 3,
       'false_info': 3,
       'offensive': 4,
       'other': 5           // 最低优先级
     };

     return priorityMap[reasonType] || 5;
   };
   ```

7. **检查自动处理条件**
   ```typescript
   const checkAutoModeration = async (targetType: string, targetId: string) => {
     // 查询该目标的举报数量
     const reportCount = await reportRepository.count({
       where: {
         targetType,
         targetId,
         createdAt: MoreThan(new Date(Date.now() - 24 * 60 * 60 * 1000))
       }
     });

     // 24小时内举报超过10次,自动下架
     if (reportCount >= 10) {
       await autoTakedown(targetType, targetId);
     }
   };
   ```

8. **异步任务**
   ```typescript
   // 推送到审核队列
   await pushToModerationQueue({
     reportId: report.id,
     priority: report.priority
   });

   // 发送通知给管理员
   await notifyModerators({
     reportId: report.id,
     reasonType: report.reasonType
   });
   ```

9. **返回结果**
   ```json
   {
     "code": 200,
     "message": "已收到您的举报,我们会尽快处理",
     "data": {
       "reportId": "report_xxx",
       "status": "pending",
       "createdAt": 1234567890000
     }
   }
   ```

---

### 2. 查看我的举报记录

**接口:** `GET /api/v1/report/my-reports`

**查询参数:**
```typescript
{
  page: number;        // 页码,默认1
  pageSize: number;    // 每页数量,默认20
  status?: string;     // 状态筛选: pending/processing/approved/rejected
}
```

**业务逻辑:**

1. **验证用户登录**
   ```typescript
   const userId = req.user.id;
   ```

2. **查询举报列表**
   ```typescript
   const queryReports = async (userId: string, page: number, pageSize: number, status?: string) => {
     const query = reportRepository
       .createQueryBuilder('report')
       .where('report.userId = :userId', { userId })
       .orderBy('report.createdAt', 'DESC')
       .skip((page - 1) * pageSize)
       .take(pageSize);

     if (status) {
       query.andWhere('report.status = :status', { status });
     }

     const [reports, total] = await query.getManyAndCount();

     return {
       list: reports,
       total,
       hasMore: total > page * pageSize
     };
   };
   ```

3. **返回结果**
   ```json
   {
     "code": 200,
     "message": "success",
     "data": {
       "list": [
         {
           "id": "report_xxx",
           "targetType": "feed",
           "targetId": "feed_xxx",
           "reasonType": "harassment",
           "description": "该用户发布辱骂内容",
           "status": "approved",
           "result": "该内容已被下架,发布者已被警告",
           "createdAt": 1234567890000,
           "updatedAt": 1234567890000
         }
       ],
       "total": 5,
       "hasMore": false
     }
   }
   ```

---

### 3. 审核举报(管理员)

**接口:** `POST /api/v1/report/moderate`

**请求体:**
```typescript
{
  reportId: string;        // 举报ID
  action: string;          // 处理动作: approve/reject
  result: string;          // 处理结果说明,1-500字符
  punishment?: {           // 处罚措施(可选)
    type: string;          // 处罚类型: takedown/mute/ban
    duration?: number;     // 处罚时长(秒),0=永久
    reason: string;        // 处罚原因
  };
}
```

**业务逻辑:**

1. **验证管理员权限**
   ```typescript
   const checkAdminPermission = (user: User) => {
     if (!user.isAdmin && !user.isModerator) {
       throw new Error('权限不足');
     }
   };
   ```

2. **查询举报记录**
   ```typescript
   const report = await reportRepository.findOne({
     where: { id: reportId }
   });

   if (!report) {
     throw new Error('举报记录不存在');
   }

   if (report.status !== 'pending' && report.status !== 'processing') {
     throw new Error('该举报已被处理');
   }
   ```

3. **更新举报状态**
   ```typescript
   report.status = action === 'approve' ? 'approved' : 'rejected';
   report.result = result;
   report.moderatorId = req.user.id;
   report.moderatedAt = new Date();

   await reportRepository.save(report);
   ```

4. **执行处罚措施(如果举报通过)**
   ```typescript
   if (action === 'approve' && punishment) {
     await executePunishment({
       targetType: report.targetType,
       targetId: report.targetId,
       punishmentType: punishment.type,
       duration: punishment.duration,
       reason: punishment.reason,
       moderatorId: req.user.id
     });
   }
   ```

5. **发送通知**
   ```typescript
   // 通知举报人
   await notifyReporter({
     userId: report.userId,
     reportId: report.id,
     status: report.status,
     result: report.result
   });

   // 通知被举报人(如果举报通过)
   if (action === 'approve') {
     await notifyReportedUser({
       targetType: report.targetType,
       targetId: report.targetId,
       reason: punishment?.reason
     });
   }
   ```

6. **返回结果**
   ```json
   {
     "code": 200,
     "message": "处理成功",
     "data": {
       "reportId": "report_xxx",
       "status": "approved",
       "moderatedAt": 1234567890000
     }
   }
   ```

---

### 4. 获取待审核队列(管理员)

**接口:** `GET /api/v1/report/queue`

**查询参数:**
```typescript
{
  page: number;        // 页码,默认1
  pageSize: number;    // 每页数量,默认20
  priority?: number;   // 优先级筛选: 1-5
  reasonType?: string; // 举报类型筛选
}
```

**业务逻辑:**

1. **验证管理员权限**

2. **查询待审核列表**
   ```typescript
   const queryQueue = async (options: QueueOptions) => {
     const query = reportRepository
       .createQueryBuilder('report')
       .where('report.status IN (:...statuses)', { statuses: ['pending', 'processing'] })
       .orderBy('report.priority', 'ASC')
       .addOrderBy('report.createdAt', 'ASC')
       .skip((options.page - 1) * options.pageSize)
       .take(options.pageSize);

     if (options.priority) {
       query.andWhere('report.priority = :priority', { priority: options.priority });
     }

     if (options.reasonType) {
       query.andWhere('report.reasonType = :reasonType', { reasonType: options.reasonType });
     }

     const [reports, total] = await query.getManyAndCount();

     return {
       list: reports,
       total,
       hasMore: total > options.page * options.pageSize
     };
   };
   ```

3. **返回结果**
   ```json
   {
     "code": 200,
     "message": "success",
     "data": {
       "list": [
         {
           "id": "report_xxx",
           "userId": "user_xxx",
           "targetType": "feed",
           "targetId": "feed_xxx",
           "reasonType": "pornography",
           "description": "发布色情内容",
           "evidenceImages": ["https://cdn.example.com/evidence1.jpg"],
           "priority": 1,
           "status": "pending",
           "createdAt": 1234567890000
         }
       ],
       "total": 25,
       "hasMore": true
     }
   }
   ```

---

### 5. 获取举报统计(管理员)

**接口:** `GET /api/v1/report/statistics`

**查询参数:**
```typescript
{
  startDate?: number;  // 开始时间戳,默认30天前
  endDate?: number;    // 结束时间戳,默认当前
}
```

**业务逻辑:**

1. **验证管理员权限**

2. **统计举报数据**
   ```typescript
   const getStatistics = async (startDate: Date, endDate: Date) => {
     // 总举报数
     const totalReports = await reportRepository.count({
       where: {
         createdAt: Between(startDate, endDate)
       }
     });

     // 按状态分组
     const statusStats = await reportRepository
       .createQueryBuilder('report')
       .select('report.status', 'status')
       .addSelect('COUNT(*)', 'count')
       .where('report.createdAt BETWEEN :start AND :end', {
         start: startDate,
         end: endDate
       })
       .groupBy('report.status')
       .getRawMany();

     // 按举报类型分组
     const reasonStats = await reportRepository
       .createQueryBuilder('report')
       .select('report.reasonType', 'reasonType')
       .addSelect('COUNT(*)', 'count')
       .where('report.createdAt BETWEEN :start AND :end', {
         start: startDate,
         end: endDate
       })
       .groupBy('report.reasonType')
       .orderBy('count', 'DESC')
       .getRawMany();

     // 按目标类型分组
     const targetTypeStats = await reportRepository
       .createQueryBuilder('report')
       .select('report.targetType', 'targetType')
       .addSelect('COUNT(*)', 'count')
       .where('report.createdAt BETWEEN :start AND :end', {
         start: startDate,
         end: endDate
       })
       .groupBy('report.targetType')
       .getRawMany();

     return {
       totalReports,
       statusStats,
       reasonStats,
       targetTypeStats
     };
   };
   ```

3. **返回结果**
   ```json
   {
     "code": 200,
     "message": "success",
     "data": {
       "totalReports": 1254,
       "statusStats": [
         { "status": "approved", "count": 654 },
         { "status": "rejected", "count": 400 },
         { "status": "pending", "count": 200 }
       ],
       "reasonStats": [
         { "reasonType": "harassment", "count": 450 },
         { "reasonType": "pornography", "count": 320 },
         { "reasonType": "fraud", "count": 200 }
       ],
       "targetTypeStats": [
         { "targetType": "feed", "count": 800 },
         { "targetType": "comment", "count": 300 },
         { "targetType": "user", "count": 154 }
       ]
     }
   }
   ```

---

## 数据模型

### Report (举报表)

```typescript
@Entity('report')
class Report {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  userId: string;           // 举报人ID

  @Column({ length: 20 })
  targetType: string;       // 举报对象类型: feed/comment/user/message/order

  @Column()
  targetId: string;         // 举报对象ID

  @Column({ length: 50 })
  reasonType: string;       // 举报原因类型

  @Column({ type: 'text', nullable: true })
  description: string;      // 举报描述

  @Column({ type: 'json', nullable: true })
  evidenceImages: string[]; // 证据图片(JSON数组)

  @Column({ length: 20, default: 'pending' })
  status: string;           // 状态: pending/processing/approved/rejected

  @Column({ type: 'int', default: 5 })
  priority: number;         // 优先级: 1-5(1最高)

  @Column({ type: 'text', nullable: true })
  result: string;           // 处理结果说明

  @Column({ nullable: true })
  moderatorId: string;      // 审核人ID

  @Column({ type: 'timestamp', nullable: true })
  moderatedAt: Date;        // 审核时间

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @Index(['userId', 'targetType', 'targetId', 'createdAt'])
  @Index(['status', 'priority', 'createdAt'])
  @Index(['targetType', 'targetId'])
  @Index(['reasonType'])
}
```

---

### Punishment (处罚表)

```typescript
@Entity('punishment')
class Punishment {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  reportId: string;         // 关联的举报ID

  @Column({ length: 20 })
  targetType: string;       // 处罚对象类型

  @Column()
  targetId: string;         // 处罚对象ID

  @Column({ length: 50 })
  punishmentType: string;   // 处罚类型: takedown/mute/ban

  @Column({ type: 'int', nullable: true })
  duration: number;         // 处罚时长(秒),0=永久

  @Column({ type: 'text' })
  reason: string;           // 处罚原因

  @Column()
  moderatorId: string;      // 处罚执行人ID

  @Column({ type: 'timestamp', nullable: true })
  expiresAt: Date;          // 处罚到期时间

  @Column({ type: 'tinyint', default: 1 })
  active: number;           // 是否生效: 0=已解除,1=生效中

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @Index(['targetType', 'targetId', 'active'])
  @Index(['reportId'])
}
```

---

## RPC接口实现

### ReportService RPC接口

提供给其他服务调用的RPC方法:

```typescript
class ReportService {
  // 提交举报
  async submitReport(params: {
    userId: string;
    targetType: string;
    targetId: string;
    reasonType: string;
    description?: string;
    evidenceImages?: string[];
  }): Promise<ReportResult> {
    // 实现逻辑...
    return {
      reportId: 'report_xxx',
      status: 'pending',
      createdAt: Date.now()
    };
  }

  // 查询举报记录
  async getReports(params: {
    userId: string;
    page: number;
    pageSize: number;
    status?: string;
  }): Promise<ReportListResult> {
    // 实现逻辑...
    return {
      list: [],
      total: 0,
      hasMore: false
    };
  }

  // 检查对象是否被处罚
  async checkPunishment(params: {
    targetType: string;
    targetId: string;
  }): Promise<PunishmentStatus> {
    const punishment = await punishmentRepository.findOne({
      where: {
        targetType: params.targetType,
        targetId: params.targetId,
        active: 1
      }
    });

    if (!punishment) {
      return {
        isPunished: false
      };
    }

    // 检查是否过期
    if (punishment.expiresAt && punishment.expiresAt < new Date()) {
      punishment.active = 0;
      await punishmentRepository.save(punishment);

      return {
        isPunished: false
      };
    }

    return {
      isPunished: true,
      punishmentType: punishment.punishmentType,
      reason: punishment.reason,
      expiresAt: punishment.expiresAt?.getTime()
    };
  }

  // 审核举报(管理员)
  async moderateReport(params: {
    reportId: string;
    moderatorId: string;
    action: 'approve' | 'reject';
    result: string;
    punishment?: PunishmentData;
  }): Promise<boolean> {
    // 实现逻辑...
    return true;
  }
}
```

**其他服务调用示例:**
```typescript
// 在ContentService中调用
import { ReportServiceClient } from '@/rpc/ReportServiceClient';

const reportClient = new ReportServiceClient();

// 检查内容是否被处罚
const punishment = await reportClient.checkPunishment({
  targetType: 'feed',
  targetId: feedId
});

if (punishment.isPunished) {
  throw new Error('该内容已被下架');
}
```

---

## 处罚执行

### 处罚类型

1. **内容下架(takedown)**
   ```typescript
   const executeTakedown = async (targetType: string, targetId: string) => {
     switch (targetType) {
       case 'feed':
         await feedRepository.update(
           { id: targetId },
           { status: 2, deleted: 1 }  // status=2(已下架), deleted=1
         );
         break;
       case 'comment':
         await commentRepository.update(
           { id: targetId },
           { deleted: 1 }
         );
         break;
     }
   };
   ```

2. **用户禁言(mute)**
   ```typescript
   const executeMute = async (userId: string, duration: number) => {
     const expiresAt = duration === 0
       ? null  // 永久禁言
       : new Date(Date.now() + duration * 1000);

     await userRepository.update(
       { id: userId },
       {
         isMuted: true,
         mutedUntil: expiresAt
       }
     );
   };
   ```

3. **账号封禁(ban)**
   ```typescript
   const executeBan = async (userId: string, duration: number) => {
     const expiresAt = duration === 0
       ? null  // 永久封禁
       : new Date(Date.now() + duration * 1000);

     await userRepository.update(
       { id: userId },
       {
         isBanned: true,
         bannedUntil: expiresAt,
         status: 2  // 账号已封禁
       }
     );
   };
   ```

---

## 自动审核

### 敏感词检测

```typescript
import Filter from 'bad-words-zh';

const sensitiveWordFilter = new Filter();

const checkSensitiveWords = (content: string): boolean => {
  return sensitiveWordFilter.isProfane(content);
};
```

### 图像识别(集成第三方API)

```typescript
// 接入阿里云内容安全API
import AliyunContentSafety from '@alicloud/content-safety';

const scanImage = async (imageUrl: string) => {
  const client = new AliyunContentSafety({
    accessKeyId: process.env.ALIYUN_ACCESS_KEY_ID,
    accessKeySecret: process.env.ALIYUN_ACCESS_KEY_SECRET
  });

  const result = await client.scanImage({
    url: imageUrl,
    scenes: ['porn', 'terrorism', 'ad', 'qrcode']
  });

  // result.suggestion: pass/review/block
  return {
    safe: result.suggestion === 'pass',
    suggestion: result.suggestion,
    labels: result.results.map(r => r.label)
  };
};
```

---

## 性能优化

### 1. 举报去重

```typescript
// 使用Redis实现24小时内去重
const checkDuplicateReportRedis = async (
  userId: string,
  targetType: string,
  targetId: string
): Promise<boolean> => {
  const key = `report:duplicate:${userId}:${targetType}:${targetId}`;
  const exists = await redis.exists(key);

  if (exists) {
    return true;  // 重复举报
  }

  // 设置24小时过期
  await redis.setex(key, 86400, '1');
  return false;
};
```

### 2. 自动处理阈值

```typescript
// 使用Redis计数器统计举报数
const incrementReportCount = async (
  targetType: string,
  targetId: string
): Promise<number> => {
  const key = `report:count:${targetType}:${targetId}`;
  const count = await redis.incr(key);

  // 设置24小时过期
  if (count === 1) {
    await redis.expire(key, 86400);
  }

  return count;
};
```

### 3. 审核队列优化

```typescript
// 使用Redis有序集合实现优先级队列
const pushToModerationQueue = async (report: Report) => {
  const score = report.priority * 1000000 + report.createdAt.getTime();
  await redis.zadd('moderation:queue', score, report.id);
};

const popFromModerationQueue = async (): Promise<string | null> => {
  const result = await redis.zpopmin('moderation:queue');
  return result ? result[0] : null;
};
```

---

## 监控与日志

### 监控指标

- 举报提交数/小时
- 待审核队列长度
- 审核响应时间(P50, P95, P99)
- 自动处理命中率
- 各举报类型占比
- 处罚执行成功率

### 日志记录

```typescript
logger.info('Report submitted', {
  reportId: report.id,
  userId: report.userId,
  targetType: report.targetType,
  targetId: report.targetId,
  reasonType: report.reasonType,
  priority: report.priority
});

logger.warn('Auto takedown triggered', {
  targetType,
  targetId,
  reportCount,
  threshold: 10
});

logger.info('Report moderated', {
  reportId: report.id,
  moderatorId: report.moderatorId,
  action: report.status,
  responseTime: Date.now() - report.createdAt.getTime()
});
```

---

## 测试用例

### 单元测试

- [ ] 提交举报成功
- [ ] 重复举报验证
- [ ] 举报原因类型验证
- [ ] 优先级计算正确
- [ ] 自动下架阈值触发
- [ ] 处罚执行成功
- [ ] 处罚到期自动解除

### 集成测试

- [ ] RPC调用成功
- [ ] 敏感词检测成功
- [ ] 图像识别API调用成功
- [ ] 通知发送成功

### 性能测试

- [ ] 举报提交<100ms
- [ ] 并发100请求/秒稳定
- [ ] 队列处理延迟<1秒

---

## 配置参数

### 环境变量

```bash
# 自动处理阈值
AUTO_TAKEDOWN_THRESHOLD=10       # 24小时内举报超过10次自动下架

# 优先级配置
HIGH_PRIORITY_REASONS=illegal,pornography,underage

# 第三方API
ALIYUN_ACCESS_KEY_ID=your_key
ALIYUN_ACCESS_KEY_SECRET=your_secret
ALIYUN_CONTENT_SAFETY_ENDPOINT=https://green.cn-shanghai.aliyuncs.com
```

---

## 部署说明

### Docker部署

```dockerfile
FROM node:16-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .
RUN npm run build

EXPOSE 8008

CMD ["npm", "start"]
```

---

## 版本历史

| 版本 | 日期 | 说明 |
|------|------|------|
| 1.0.0 | 2025-01-XX | 初始版本 |
| 1.1.0 | 待定 | 增加AI自动审核 |
| 1.2.0 | 待定 | 增加申诉功能 |
