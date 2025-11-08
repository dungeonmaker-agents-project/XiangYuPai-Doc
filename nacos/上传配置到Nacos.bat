@echo off
chcp 65001 >nul
echo ================================================
echo 📤 上传 xypai-content.yml 配置到 Nacos
echo ================================================
echo.

set NACOS_SERVER=http://localhost:8848
set USERNAME=nacos
set PASSWORD=nacos
set GROUP=DEFAULT_GROUP
set NAMESPACE=dev

echo ⚠️  请确保：
echo   1. Nacos 已启动 (http://localhost:8848)
echo   2. 配置文件 xypai-content.yml 已修改
echo   3. 命名空间为 dev
echo.

pause

echo.
echo 📋 上传配置中...
echo.

:: 使用 PowerShell 读取文件并上传
powershell -Command "$content = Get-Content -Path 'xypai-content.yml' -Raw; $body = @{dataId='xypai-content.yml'; group='%GROUP%'; tenant='%NAMESPACE%'; content=$content}; Invoke-RestMethod -Uri '%NACOS_SERVER%/nacos/v1/cs/configs' -Method POST -Body $body"

echo.
echo ================================================
echo ✅ 上传完成！
echo ================================================
echo.
echo 📝 下一步：
echo   1. 访问 Nacos 控制台验证：%NACOS_SERVER%/nacos
echo   2. 重启 xypai-content 应用
echo.

pause

