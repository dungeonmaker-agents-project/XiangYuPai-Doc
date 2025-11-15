# 上传 application-common.yml 配置到 Nacos
# PowerShell 脚本

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "📤 上传 application-common.yml 配置到 Nacos" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

$NACOS_SERVER = "http://localhost:8848"
$USERNAME = "nacos"
$PASSWORD = "nacos"
$GROUP = "DEFAULT_GROUP"
$NAMESPACE = "dev"
$CONFIG_FILE = "application-common.yml"

Write-Host "⚠️  请确保：" -ForegroundColor Yellow
Write-Host "  1. Nacos 已启动 (http://localhost:8848)" -ForegroundColor Yellow
Write-Host "  2. 配置文件 application-common.yml 已修改" -ForegroundColor Yellow
Write-Host "  3. 命名空间为 dev" -ForegroundColor Yellow
Write-Host ""
Write-Host "🔧 本次修改：" -ForegroundColor Green
Write-Host "  - dubbo.consumer.timeout: 3000 → 10000 (修复 RPC 超时)" -ForegroundColor Green
Write-Host ""

# 检查文件是否存在
if (-not (Test-Path $CONFIG_FILE)) {
    Write-Host "❌ 错误：找不到配置文件 $CONFIG_FILE" -ForegroundColor Red
    Read-Host "按回车键退出"
    exit 1
}

# 读取配置内容
Write-Host "📋 读取配置文件..." -ForegroundColor White
$content = Get-Content -Path $CONFIG_FILE -Raw -Encoding UTF8

# 构建请求体
$body = @{
    dataId   = $CONFIG_FILE
    group    = $GROUP
    tenant   = $NAMESPACE
    content  = $content
    username = $USERNAME
    password = $PASSWORD
}

try {
    Write-Host "📤 上传配置到 Nacos..." -ForegroundColor White
    
    $response = Invoke-RestMethod -Uri "$NACOS_SERVER/nacos/v1/cs/configs" -Method POST -Body $body
    
    if ($response -eq "true") {
        Write-Host ""
        Write-Host "================================================" -ForegroundColor Green
        Write-Host "✅ 上传成功！" -ForegroundColor Green
        Write-Host "================================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "📝 下一步：" -ForegroundColor Cyan
        Write-Host "  1. 访问 Nacos 控制台验证：$NACOS_SERVER/nacos" -ForegroundColor White
        Write-Host "  2. 搜索配置 ID: $CONFIG_FILE" -ForegroundColor White
        Write-Host "  3. 确认 dubbo.consumer.timeout 已更新为 10000" -ForegroundColor White
        Write-Host "  4. 重启以下服务使配置生效：" -ForegroundColor Yellow
        Write-Host "     - ruoyi-auth" -ForegroundColor White
        Write-Host "     - ruoyi-gateway" -ForegroundColor White
        Write-Host "     - ruoyi-system" -ForegroundColor White
        Write-Host "     - xypai-* 所有服务" -ForegroundColor White
        Write-Host ""
        Write-Host "⚠️  注意：重启后需要观察日志，确认不再出现 Dubbo 超时错误" -ForegroundColor Yellow
        Write-Host ""
    } else {
        Write-Host ""
        Write-Host "❌ 上传失败：$response" -ForegroundColor Red
        Write-Host ""
    }
}
catch {
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Red
    Write-Host "❌ 上传失败！" -ForegroundColor Red
    Write-Host "================================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "错误信息：$($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "可能的原因：" -ForegroundColor Yellow
    Write-Host "  1. Nacos 未启动" -ForegroundColor White
    Write-Host "  2. 用户名密码错误" -ForegroundColor White
    Write-Host "  3. 命名空间不存在" -ForegroundColor White
    Write-Host "  4. 网络连接问题" -ForegroundColor White
    Write-Host ""
}

Read-Host "按回车键退出"

