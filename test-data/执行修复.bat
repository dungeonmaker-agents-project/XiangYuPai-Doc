@echo off
chcp 65001 >nul
echo ========================================
echo 🚨 紧急修复 sys_client 表性能问题
echo ========================================
echo.

set MYSQL_PATH=C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe
set DOCKER_MYSQL=docker exec -i mysql mysql

echo 请选择执行方式：
echo   1. 本机 MySQL (默认路径)
echo   2. Docker MySQL 容器
echo   3. 自定义 MySQL 路径
echo.

set /p choice="请输入选择 (1/2/3): "

if "%choice%"=="2" (
    echo.
    echo 📦 使用 Docker MySQL...
    echo.
    %DOCKER_MYSQL% -uroot -pruoyi123 ^< URGENT_FIX_sys_client_index.sql
    goto end
)

if "%choice%"=="3" (
    echo.
    set /p MYSQL_PATH="请输入 mysql.exe 完整路径: "
)

echo.
echo 🔧 执行 SQL 修复...
echo.

"%MYSQL_PATH%" -uroot -pruoyi123 ^< URGENT_FIX_sys_client_index.sql

:end
echo.
echo ========================================
echo ✅ 修复完成！
echo ========================================
echo.
echo 📝 下一步：
echo   1. 重启 ruoyi-auth 服务
echo   2. 重启 ruoyi-system 服务  
echo   3. 测试登录功能
echo.

pause

