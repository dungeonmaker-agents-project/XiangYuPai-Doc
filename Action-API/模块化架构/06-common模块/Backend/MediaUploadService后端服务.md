# MediaUploadService 后端服务文档

## 服务概述

MediaUploadService是通用媒体上传服务,负责处理图片和视频的上传、压缩、存储等功能。该服务为全平台提供统一的媒体上传能力,被多个模块调用(内容、用户、交易、聊天等)。

**服务名称:** xypai-media-upload
**服务端口:** 8006
**所属模块:** 06-common模块
**数据库:** xypai_common
**技术栈:** Node.js + TypeScript + Express + Multer + Sharp + FFmpeg + OSS/S3

---

## 服务架构

### 核心功能

1. **图片上传**
   - 支持格式: JPG, PNG, WEBP, HEIC
   - 自动压缩(可配置质量和尺寸)
   - 生成缩略图
   - 上传到对象存储(OSS/S3)

2. **视频上传**
   - 支持格式: MP4, MOV, AVI, FLV
   - 生成封面图(第1帧)
   - 视频转码(可选)
   - 上传到对象存储

3. **安全控制**
   - 文件格式验证
   - 文件大小限制
   - 内容安全检测(可选)
   - 上传频率限制

---

## API接口

### 1. 上传媒体文件

**接口:** `POST /api/v1/media/upload`

**Content-Type:** `multipart/form-data`

**请求参数:**
```typescript
{
  file: File;           // 文件对象,必填
  type: 'image' | 'video';  // 媒体类型,必填

  // 图片参数(type=image时)
  quality?: number;     // 压缩质量,0.1-1.0,默认0.8
  maxWidth?: number;    // 最大宽度,默认1920
  maxHeight?: number;   // 最大高度,默认1920
  generateThumbnail?: boolean; // 是否生成缩略图,默认true

  // 视频参数(type=video时)
  generateCover?: boolean;  // 是否生成封面,默认true
  coverTime?: number;       // 封面截取时间(秒),默认1
}
```

**业务逻辑:**

1. **接收文件**
   - 使用Multer中间件接收文件
   - 验证Content-Type
   - 限制文件大小:
     - 图片: ≤10MB
     - 视频: ≤100MB

2. **文件验证**
   - 验证文件扩展名
   - 验证MIME类型
   - 使用file-type库验证真实文件类型(防止伪造)

3. **图片处理(type=image)**
   ```typescript
   // 使用Sharp库处理图片
   const processImage = async (file: File, options: ImageOptions) => {
     let image = sharp(file.buffer);

     // 1. 获取图片元信息
     const metadata = await image.metadata();
     let { width, height } = metadata;

     // 2. 调整尺寸(如果超过限制)
     if (width > options.maxWidth || height > options.maxHeight) {
       const ratio = Math.min(
         options.maxWidth / width,
         options.maxHeight / height
       );
       width = Math.floor(width * ratio);
       height = Math.floor(height * ratio);
       image = image.resize(width, height);
     }

     // 3. 压缩并转换格式
     const compressed = await image
       .jpeg({ quality: Math.floor(options.quality * 100) })
       .toBuffer();

     // 4. 生成缩略图(宽度400px)
     let thumbnail = null;
     if (options.generateThumbnail) {
       thumbnail = await sharp(file.buffer)
         .resize(400, null, { withoutEnlargement: true })
         .jpeg({ quality: 80 })
         .toBuffer();
     }

     return { compressed, thumbnail, width, height };
   };
   ```

4. **视频处理(type=video)**
   ```typescript
   // 使用FFmpeg处理视频
   const processVideo = async (file: File, options: VideoOptions) => {
     // 1. 获取视频元信息
     const metadata = await getVideoMetadata(file);
     const { width, height, duration } = metadata;

     // 2. 验证时长(1-300秒)
     if (duration < 1 || duration > 300) {
       throw new Error('视频时长必须在1-300秒之间');
     }

     // 3. 生成封面图(截取第1秒)
     let cover = null;
     if (options.generateCover) {
       cover = await extractFrameAtTime(file, options.coverTime || 1);
       cover = await sharp(cover)
         .resize(800, null, { withoutEnlargement: true })
         .jpeg({ quality: 85 })
         .toBuffer();
     }

     return { width, height, duration, cover };
   };
   ```

5. **上传到对象存储**
   ```typescript
   const uploadToOSS = async (buffer: Buffer, type: string): Promise<string> => {
     // 生成唯一文件名
     const ext = type === 'image' ? 'jpg' : 'mp4';
     const fileName = `${Date.now()}_${randomUUID()}.${ext}`;
     const filePath = `media/${type}/${fileName}`;

     // 上传到OSS
     await ossClient.put(filePath, buffer);

     // 返回CDN URL
     return `https://cdn.xiangyupai.com/${filePath}`;
   };
   ```

6. **创建媒体记录**
   ```typescript
   const createMediaRecord = async (data: MediaData) => {
     const media = new Media();
     media.id = generateUUID();
     media.type = data.type;
     media.url = data.url;
     media.thumbnailUrl = data.thumbnailUrl;
     media.width = data.width;
     media.height = data.height;
     media.duration = data.duration;
     media.fileSize = data.fileSize;
     media.uploadBy = data.userId;
     await mediaRepository.save(media);

     return media.id;
   };
   ```

7. **返回结果**
   ```json
   {
     "code": 200,
     "message": "上传成功",
     "data": {
       "mediaId": "media_xxx",
       "url": "https://cdn.xiangyupai.com/media/image/xxx.jpg",
       "thumbnailUrl": "https://cdn.xiangyupai.com/media/image/xxx_thumb.jpg",
       "width": 1920,
       "height": 1080,
       "duration": null,
       "fileSize": 1024000
     }
   }
   ```

**错误处理:**
- 400: 文件格式不支持
- 413: 文件过大
- 500: 上传失败

---

### 2. 批量上传图片(可选)

**接口:** `POST /api/v1/media/upload/batch`

**Content-Type:** `multipart/form-data`

**请求参数:**
```typescript
{
  files: File[];        // 文件数组,最多9个
  quality?: number;
  maxWidth?: number;
  maxHeight?: number;
}
```

**业务逻辑:**
1. 验证文件数量(最多9个)
2. 并发处理所有文件(Promise.all)
3. 返回所有文件的上传结果

**响应示例:**
```json
{
  "code": 200,
  "message": "批量上传成功",
  "data": {
    "success": [
      {
        "mediaId": "media_1",
        "url": "https://cdn.xiangyupai.com/xxx1.jpg"
      },
      {
        "mediaId": "media_2",
        "url": "https://cdn.xiangyupai.com/xxx2.jpg"
      }
    ],
    "failed": []
  }
}
```

---

### 3. 获取上传进度(WebSocket,可选)

**接口:** `WS /api/v1/media/upload/progress`

**功能:** 实时推送上传进度

**消息格式:**
```json
{
  "uploadId": "upload_xxx",
  "progress": 45,
  "status": "uploading",
  "message": "上传中..."
}
```

---

## 数据模型

### Media (媒体表)

```typescript
@Entity('media')
class Media {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ length: 20 })
  type: string;             // image/video

  @Column({ length: 255 })
  url: string;              // 完整URL

  @Column({ length: 255, nullable: true })
  thumbnailUrl: string;     // 缩略图URL

  @Column({ type: 'int' })
  width: number;

  @Column({ type: 'int' })
  height: number;

  @Column({ type: 'int', nullable: true })
  duration: number;         // 视频时长(秒)

  @Column({ type: 'bigint' })
  fileSize: number;         // 文件大小(字节)

  @Column({ nullable: true })
  uploadBy: string;         // 上传用户ID

  @Column({ type: 'tinyint', default: 0 })
  status: number;           // 0=正常,1=已删除

  @CreateDateColumn()
  createdAt: Date;

  @Index(['uploadBy'])
  @Index(['type'])
}
```

---

## RPC接口实现

### MediaUploadService RPC接口

提供给其他服务调用的RPC方法:

```typescript
class MediaUploadService {
  // 上传单个文件
  async uploadMedia(params: {
    fileBuffer: Buffer;
    fileName: string;
    type: 'image' | 'video';
    quality?: number;
    maxWidth?: number;
    maxHeight?: number;
  }): Promise<MediaUploadResult> {
    // 实现逻辑...
    return {
      mediaId: 'media_xxx',
      url: 'https://cdn.xiangyupai.com/xxx.jpg',
      thumbnailUrl: 'https://cdn.xiangyupai.com/xxx_thumb.jpg',
      width: 1920,
      height: 1080
    };
  }

  // 批量上传
  async uploadMediaBatch(params: {
    files: Array<{
      fileBuffer: Buffer;
      fileName: string;
    }>;
    type: 'image';
    quality?: number;
  }): Promise<MediaUploadResult[]> {
    // 实现逻辑...
    return [];
  }

  // 删除媒体
  async deleteMedia(mediaId: string): Promise<boolean> {
    // 实现逻辑...
    return true;
  }

  // 获取媒体信息
  async getMediaInfo(mediaId: string): Promise<Media> {
    // 实现逻辑...
    return media;
  }
}
```

**其他服务调用示例:**
```typescript
// 在ContentService中调用
import { MediaUploadServiceClient } from '@/rpc/MediaUploadServiceClient';

const mediaClient = new MediaUploadServiceClient();

const result = await mediaClient.uploadMedia({
  fileBuffer: file.buffer,
  fileName: file.originalname,
  type: 'image',
  quality: 0.8,
  maxWidth: 1920
});

console.log('上传成功:', result.mediaId, result.url);
```

---

## 性能优化

### 1. 图片压缩优化

```typescript
const compressImage = async (buffer: Buffer, quality: number) => {
  // 使用Sharp库,性能优于ImageMagick
  return await sharp(buffer)
    .jpeg({
      quality: Math.floor(quality * 100),
      chromaSubsampling: '4:4:4'  // 更好的色彩保真度
    })
    .toBuffer();
};
```

### 2. 并发上传优化

```typescript
// 限制并发数为3,避免内存溢出
const uploadBatch = async (files: File[]) => {
  const concurrency = 3;
  const results = [];

  for (let i = 0; i < files.length; i += concurrency) {
    const batch = files.slice(i, i + concurrency);
    const batchResults = await Promise.all(
      batch.map(file => uploadSingleFile(file))
    );
    results.push(...batchResults);
  }

  return results;
};
```

### 3. CDN加速

- 使用CDN分发媒体文件
- 配置缓存策略(Cache-Control: max-age=31536000)
- 使用WebP格式(支持时,文件大小减少30%)

### 4. 断点续传(大文件)

```typescript
// 使用分片上传
const uploadLargeFile = async (file: File) => {
  const chunkSize = 5 * 1024 * 1024; // 5MB per chunk
  const chunks = Math.ceil(file.size / chunkSize);

  for (let i = 0; i < chunks; i++) {
    const start = i * chunkSize;
    const end = Math.min(start + chunkSize, file.size);
    const chunk = file.slice(start, end);

    await uploadChunk(chunk, i, chunks);
  }

  await mergeChunks();
};
```

---

## 安全机制

### 1. 文件类型验证

```typescript
import fileType from 'file-type';

const validateFileType = async (buffer: Buffer, allowedTypes: string[]) => {
  const type = await fileType.fromBuffer(buffer);

  if (!type || !allowedTypes.includes(type.mime)) {
    throw new Error('文件类型不支持');
  }

  return type;
};
```

### 2. 内容安全检测

```typescript
// 接入阿里云内容安全API
const checkContentSafety = async (imageUrl: string) => {
  const result = await aliyunContentSafety.scanImage(imageUrl);

  if (result.suggestion === 'block') {
    throw new Error('图片内容违规');
  }

  return result;
};
```

### 3. 上传频率限制

```typescript
// 使用Redis限流
const checkUploadRateLimit = async (userId: string) => {
  const key = `upload:limit:${userId}`;
  const count = await redis.incr(key);

  if (count === 1) {
    await redis.expire(key, 3600); // 1小时过期
  }

  if (count > 100) {  // 1小时最多上传100次
    throw new Error('上传过于频繁,请稍后再试');
  }
};
```

---

## 监控与日志

### 监控指标

- 上传成功率
- 上传耗时(P50, P95, P99)
- OSS存储使用量
- CDN流量
- 图片压缩比
- 错误类型分布

### 日志记录

```typescript
logger.info('Media upload', {
  userId,
  type: 'image',
  originalSize: file.size,
  compressedSize: compressed.length,
  compressionRatio: (compressed.length / file.size).toFixed(2),
  uploadTime: Date.now() - startTime,
  url: result.url
});
```

---

## 配置参数

### 环境变量

```bash
# OSS配置
OSS_ENDPOINT=oss-cn-shenzhen.aliyuncs.com
OSS_ACCESS_KEY=your_access_key
OSS_SECRET_KEY=your_secret_key
OSS_BUCKET=xiangyupai-media
OSS_CDN_DOMAIN=cdn.xiangyupai.com

# 文件大小限制
MAX_IMAGE_SIZE=10485760    # 10MB
MAX_VIDEO_SIZE=104857600   # 100MB

# 图片压缩参数
DEFAULT_IMAGE_QUALITY=0.8
DEFAULT_MAX_WIDTH=1920
DEFAULT_MAX_HEIGHT=1920

# 视频参数
MAX_VIDEO_DURATION=300     # 5分钟
```

---

## 测试用例

### 单元测试

- [ ] 图片上传成功
- [ ] 图片压缩成功
- [ ] 生成缩略图成功
- [ ] 视频上传成功
- [ ] 生成视频封面成功
- [ ] 文件格式验证
- [ ] 文件大小验证
- [ ] 视频时长验证

### 集成测试

- [ ] 上传到OSS成功
- [ ] 批量上传成功
- [ ] RPC调用成功

### 性能测试

- [ ] 单个10MB图片上传<2秒
- [ ] 单个100MB视频上传<10秒
- [ ] 批量上传9张图片<5秒
- [ ] 并发100请求/秒稳定

---

## 部署说明

### Docker部署

```dockerfile
FROM node:16-alpine

# 安装FFmpeg
RUN apk add --no-cache ffmpeg

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .
RUN npm run build

EXPOSE 8006

CMD ["npm", "start"]
```

### 启动命令

```bash
npm run build
npm start
```

---

## 版本历史

| 版本 | 日期 | 说明 |
|------|------|------|
| 1.0.0 | 2025-01-XX | 初始版本 |
| 1.1.0 | 待定 | 增加WebP支持 |
| 1.2.0 | 待定 | 增加断点续传 |
| 2.0.0 | 待定 | 增加视频转码 |
