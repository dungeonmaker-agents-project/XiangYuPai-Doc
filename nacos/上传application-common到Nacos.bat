@echo off
chcp 65001 >nul
echo ================================================
echo 📤 上传 application-common.yml 配置到 Nacos
echo ================================================
echo.

set NACOS_SERVER=http://localhost:8848
set USERNAME=nacos
set PASSWORD=nacos
set GROUP=DEFAULT_GROUP
set NAMESPACE=dev

echo ⚠️  请确保：
echo   1. Nacos 已启动 (http://localhost:8848)
echo   2. 配置文件 application-common.yml 已修改
echo   3. 命名空间为 dev
echo.
echo 🔧 本次修改：
echo   - dubbo.consumer.timeout: 3000 → 10000 (修复 RPC 超时)
echo.

pause

echo.
echo 📋 上传配置中...
echo.

:: 使用 PowerShell 读取文件并上传
powershell -Command "$content = Get-Content -Path 'application-common.yml' -Raw; $body = @{dataId='application-common.yml'; group='%GROUP%'; tenant='%NAMESPACE%'; content=$content; username='%USERNAME%'; password='%PASSWORD%'}; $response = Invoke-RestMethod -Uri '%NACOS_SERVER%/nacos/v1/cs/configs' -Method POST -Body $body; Write-Host $response"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ================================================
    echo ✅ 上传完成！
    echo ================================================
    echo.
    echo 📝 下一步：
    echo   1. 访问 Nacos 控制台验证：%NACOS_SERVER%/nacos
    echo   2. 搜索配置 ID: application-common.yml
    echo   3. 确认 dubbo.consumer.timeout 已更新为 10000
    echo   4. 重启以下服务使配置生效：
    echo      - ruoyi-auth
    echo      - ruoyi-gateway
    echo      - ruoyi-system
    echo      - xypai-* 所有服务
    echo.
    echo ⚠️  注意：重启后需要观察日志，确认不再出现 Dubbo 超时错误
    echo.
) else (
    echo.
    echo ================================================
    echo ❌ 上传失败！
    echo ================================================
    echo.
    echo 可能的原因：
    echo   1. Nacos 未启动
    echo   2. 用户名密码错误
    echo   3. 命名空间不存在
    echo.
)

pause

