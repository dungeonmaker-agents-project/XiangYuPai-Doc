# 🔐 Alice - 认证安全模块

> **负责人**: Alice (后端认证安全工程师)  
> **模块**: xypai-auth (认证安全服务)  
> **数据库**: xypai_auth  
> **服务端口**: 9405  
> **优先级**: P0（最高优先级）

---

## 📋 负责范围

### 核心表（5张表，71字段）

| 表名 | 字段数 | 索引数 | 说明 | 参考PL.md |
|------|--------|--------|------|-----------|
| login_session | 22 | 6 | 登录会话管理 | 291-340行 |
| sms_verification | 15 | 4 | 短信验证码 | 342-381行 |
| user_device | 18 | 4 | 设备管理 | 426-475行 |
| phone_verify_limit | 9 | 3 | 防穷举限制 | 594-620行 |
| token_blacklist | 7 | 4 | Token黑名单 | 568-591行 |

**总计**: 71字段，21个索引

### 核心功能（20个API）

**基础认证** (9个):
- 密码登录、短信登录
- Token刷新、用户登出
- 发送验证码、验证验证码
- Token验证、心跳保活、健康检查

**设备管理** (6个):
- 设备列表、信任设备列表
- 设置信任、取消信任
- 注销设备、删除设备

**会话管理** (5个):
- 会话列表、当前会话
- 注销会话、注销其他会话
- 会话统计

---

## 🚀 快速启动

### Step 1: 启动统一Docker环境
```bash
# 返回dev_workspace根目录
cd ../../

# 启动所有服务（MySQL + Redis + Nacos等）
cd docker
docker-compose -f docker-compose-all.yml up -d

# 等待30秒让MySQL完全启动
```

### Step 2: 初始化认证模块数据库
```bash
# 返回Alice的目录
cd ../team/alice/sql

# 方式1: 一键初始化（推荐）
mysql -h 127.0.0.1 -u root -proot xypai_auth < 00_reset_all.sql

# 方式2: 分步执行
mysql -h 127.0.0.1 -u root -proot xypai_auth < 02_create_tables.sql
mysql -h 127.0.0.1 -u root -proot xypai_auth < 03_create_indexes.sql
mysql -h 127.0.0.1 -u root -proot xypai_auth < 04_init_test_data.sql
```

### Step 3: 启动认证服务
```bash
# 进入认证服务目录
cd ../../../../xypai-security/security-oauth

# 启动服务
mvn spring-boot:run
```

### Step 4: 验证
```bash
# 健康检查
curl http://localhost:9405/api/v1/auth/health

# API文档
http://localhost:9405/doc.html
```

---

## 📁 目录结构

```
alice/
├─ README.md                    # 本文档
├─ REQUIREMENTS.md              # 环境需求说明
│
├─ sql/                         # SQL脚本
│  ├─ 02_create_tables.sql     # 创建5张表（71字段）
│  ├─ 03_create_indexes.sql    # 创建21个索引
│  ├─ 04_init_test_data.sql    # 初始化测试数据
│  └─ 00_reset_all.sql         # 一键重置（调用02-04）
│
└─ docs/                        # 文档
   ├─ DATABASE_DESIGN.md        # 数据库设计文档
   └─ API_REFERENCE.md          # API参考文档
```

---

## 🔗 相关文档

- 📖 [数据库设计](./docs/DATABASE_DESIGN.md) - 5张表完整设计
- 📖 [环境需求](./REQUIREMENTS.md) - Docker和依赖说明
- 📖 [API参考](./docs/API_REFERENCE.md) - 20个接口文档
- 📖 [PL.md](../../../.cursor/rules/PL.md) - 第289-651行（设计蓝图）

---

## 📊 数据库容量估算

```
1万用户: 约380MB
├─ login_session: 130MB
├─ sms_verification: 200MB（30天）
├─ user_device: 35MB
├─ phone_verify_limit: 2MB
└─ token_blacklist: 11MB

10万用户: 约3.8GB
100万用户: 约38GB

推荐: 每月清理一次历史数据
```

---

## 🔗 依赖关系

### 上游服务依赖
- **xypai-user** (Bob) - Feign调用获取用户信息
- **Nacos** - 服务注册和配置中心
- **Redis** - 会话缓存和验证码存储
- **MySQL** - 数据持久化

### 下游服务使用
- **xypai-gateway** - Token验证
- **所有服务** - 通过Gateway鉴权

---

## 📞 协作信息

- **负责人**: Alice
- **协作**: Bob (User表扩展)、Jack (DBA审核)、Kate (QA测试)
- **技术栈**: Spring Boot 3.2 + MyBatis Plus 3.5.7 + JWT 0.12.3
- **代码位置**: `xypai-security/security-oauth/`

---

**🔐 认证安全 - 系统的基石！** 🚀

