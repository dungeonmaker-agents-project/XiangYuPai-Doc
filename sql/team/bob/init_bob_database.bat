@echo off
REM ==========================================
REM Bob用户模块 - 一键初始化数据库脚本
REM ==========================================

echo ========================================
echo   Bob用户模块数据库初始化
echo ========================================
echo.

cd /d "%~dp0sql"

echo [1/3] 创建表结构...
mysql -h 127.0.0.1 -u root -proot xypai_user < 02_create_tables.sql
echo   ✅ 8张表创建完成

echo.
echo [2/3] 创建索引...
mysql -h 127.0.0.1 -u root -proot xypai_user < 03_create_indexes.sql
echo   ✅ 20个索引创建完成

echo.
echo [3/3] 初始化测试数据...
mysql -h 127.0.0.1 -u root -proot xypai_user < 04_init_test_data.sql
echo   ✅ 测试数据初始化完成

echo.
echo ========================================
echo   ✅ Bob用户模块数据库初始化成功！
echo ========================================
echo.
echo 📊 数据统计：
echo   • 8张核心表
echo   • 113个字段
echo   • 20个索引
echo   • 10个测试用户
echo   • 20种预置职业
echo.
echo 🚀 下一步：
echo   cd ..\..\..\xypai-modules\xypai-user
echo   mvn spring-boot:run
echo.

pause

