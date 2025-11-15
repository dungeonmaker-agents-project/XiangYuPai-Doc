# 生成 Test@123456 的 BCrypt 哈希
# 
# 执行方法:
#   cd xypai-security\test-data
#   .\generate-password.ps1

Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "🔐 生成 Test@123456 的 BCrypt 哈希" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Cyan

$securityOAuthPath = "..\security-oauth"

# 切换到 security-oauth 目录
Set-Location $securityOAuthPath

Write-Host "📂 当前目录: $PWD`n" -ForegroundColor Yellow

# 编译 Java 类
Write-Host "🔨 编译 GeneratePassword.java..." -ForegroundColor Yellow
& mvn test-compile -DskipTests -q

if ($LASTEXITCODE -ne 0) {
    Write-Host "`n❌ 编译失败！" -ForegroundColor Red
    Set-Location -
    exit 1
}

Write-Host "✅ 编译成功！`n" -ForegroundColor Green

# 运行 Java 类
Write-Host "🚀 运行密码生成器...`n" -ForegroundColor Yellow
& mvn exec:java -Dexec.mainClass="com.xypai.auth.GeneratePassword" -Dexec.classpathScope=test -q

# 返回原目录
Set-Location ..\test-data

Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "✅ 完成！请复制上面的 SQL 到 MySQL 执行。" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Cyan

