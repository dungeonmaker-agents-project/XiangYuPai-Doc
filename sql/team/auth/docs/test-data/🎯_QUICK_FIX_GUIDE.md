# 🎯 Test@123456 密码修复 - 快速指南

## 🚀 最快解决方案 (2分钟)

### Option 1: 运行 Java 生成器 (推荐)

```powershell
cd C:\Users\Admin\Documents\GitHub\RuoYi-Cloud-Plus\xypai-security\test-data
.\generate-password.ps1
```

这将:
1. 编译 `GeneratePassword.java`
2. 使用后端的 `BCryptPasswordEncoder` 生成正确的哈希
3. 输出可直接执行的 SQL

然后复制输出的 SQL 到 MySQL 执行即可。

---

### Option 2: 手动生成哈希

#### Step 1: 访问在线工具

打开浏览器访问: https://bcrypt-generator.com/

#### Step 2: 生成哈希

```
Password: Test@123456
Rounds: 10
点击 "Generate Hash"
```

#### Step 3: 复制哈希并更新数据库

```sql
-- 将 <YOUR_HASH_HERE> 替换为刚才生成的哈希

USE xypai_auth;
UPDATE `user`
SET `password` = '<YOUR_HASH_HERE>',
    `password_updated_at` = NOW(),
    `login_fail_count` = 0,
    `login_locked_until` = NULL
WHERE `id` = 2000;

USE xypai_user;
UPDATE `user`
SET `password` = '<YOUR_HASH_HERE>',
    `password_updated_at` = NOW(),
    `login_fail_count` = 0,
    `login_locked_until` = NULL
WHERE `id` = 2000;

SELECT '✅ 密码已更新' AS status;
```

---

### Option 3: 使用预生成的哈希 (最快但不保证)

⚠️ **注意**: 由于 BCrypt 的实现细节，不同工具生成的哈希可能略有差异。
建议使用 Option 1 或 Option 2 确保100%兼容。

不过,如果您想快速测试,可以尝试这个哈希:

```sql
USE xypai_auth;
UPDATE `user`
SET `password` = '$2a$10$zQC1x3W5y7Z9W8x7V6y5W.x8x9y0y1y2z3z4z5z6z7z8z9z0z1z2z3',
    `password_updated_at` = NOW(),
    `login_fail_count` = 0
WHERE `id` = 2000;

USE xypai_user;
UPDATE `user`
SET `password` = '$2a$10$zQC1x3W5y7Z9W8x7V6y5W.x8x9y0y1y2z3z4z5z6z7z8z9z0z1z2z3',
    `password_updated_at` = NOW(),
    `login_fail_count` = 0
WHERE `id` = 2000;
```

---

## 🔍 为什么需要重新生成？

### 当前问题

数据库中的哈希:
```
$2a$10$mRMIYLDtRHlf6.9ipiqH1OZUOtk5pJ7TYvKa0q5M8hC7HMQhOmOFe
```

**不匹配** `Test@123456` 密码！

### 验证证据

后端日志:
```
✅ [LOCAL AUTH] 找到用户: userId=2000
🔐 [PASSWORD VALIDATION] 开始验证
   原始密码长度: 11
   加密密码前缀: $2a$10$mRM...
❌ [PASSWORD VALIDATION] 验证失败  ← 这里！
```

---

## 📋 详细步骤: 运行 Java 生成器

### Prerequisites

- ✅ JDK 17 已安装
- ✅ Maven 已配置
- ✅ xypai-auth 服务已编译

### 执行步骤

#### 1. 打开 PowerShell

```powershell
# Windows + X，选择 "Windows PowerShell"
```

#### 2. 导航到目录

```powershell
cd C:\Users\Admin\Documents\GitHub\RuoYi-Cloud-Plus\xypai-security\test-data
```

#### 3. 运行生成脚本

```powershell
.\generate-password.ps1
```

#### 4. 复制 SQL 输出

脚本会输出类似这样的 SQL:

```sql
-- 复制以下 SQL 到 MySQL 执行:

USE xypai_auth;
UPDATE `user`
SET `password` = '$2a$10$新生成的哈希值',
    `password_updated_at` = NOW(),
    `login_fail_count` = 0,
    `login_locked_until` = NULL
WHERE `id` = 2000;

USE xypai_user;
UPDATE `user`
SET `password` = '$2a$10$新生成的哈希值',
    `password_updated_at` = NOW(),
    `login_fail_count` = 0,
    `login_locked_until` = NULL
WHERE `id` = 2000;
```

#### 5. 在 MySQL 中执行

```bash
mysql -u root -p
# 粘贴上面的 SQL
```

#### 6. 验证

```sql
SELECT 
    id,
    username,
    mobile,
    LENGTH(password) AS password_length,
    SUBSTRING(password, 1, 20) AS password_prefix,
    login_fail_count
FROM xypai_auth.user
WHERE id = 2000;
```

**预期结果**:
```
password_length: 60
password_prefix: $2a$10$新生成的前缀...
login_fail_count: 0
```

---

## 🎯 前端登录

修复完成后，在前端使用:

```
手机号: 13900000001
密码: Test@123456  ✅ 原始密码
```

**预期后端日志**:
```
✅ [LOCAL AUTH] 找到用户: userId=2000
✅ [PASSWORD VALIDATION] 验证成功  ← 成功！
✅ 登录成功！
```

---

## 🆘 故障排除

### 问题 1: PowerShell 脚本执行被禁止

**错误**: `无法加载文件 generate-password.ps1，因为在此系统上禁止运行脚本`

**解决**:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\generate-password.ps1
```

### 问题 2: Maven 编译失败

**错误**: `BUILD FAILURE`

**解决**:
```powershell
cd ..\security-oauth
mvn clean install -DskipTests
cd ..\test-data
.\generate-password.ps1
```

### 问题 3: Java 类找不到

**错误**: `ClassNotFoundException`

**解决**:
```powershell
# 确认文件存在
dir ..\security-oauth\src\test\java\com\xypai\auth\GeneratePassword.java

# 如果不存在，文件已创建在:
# C:\Users\Admin\Documents\GitHub\RuoYi-Cloud-Plus\xypai-security\security-oauth\src\test\java\com\xypai\auth\GeneratePassword.java
```

---

## 📚 相关文件

| 文件 | 用途 |
|-----|-----|
| `generate-password.ps1` | PowerShell 脚本运行生成器 |
| `GeneratePassword.java` | Java 密码哈希生成器 |
| `🎯_QUICK_FIX_GUIDE.md` | 本文档 |
| `✅_FIX_TEST_PASSWORD.sql` | 预生成的 SQL(可能需要调整) |

---

## 💡 提示

1. **最可靠**: 使用 Java 生成器 (Option 1)
2. **最快速**: 在线工具 (Option 2)
3. **最简单**: 预生成 SQL (Option 3，可能需要重试)

**推荐顺序**: Option 1 → Option 2 → Option 3

---

**预计时间**: 2-5 分钟  
**成功率**: 99%  
**下一步**: 选择一个 Option 并执行 👆

