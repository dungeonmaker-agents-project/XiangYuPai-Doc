import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

/**
 * 密码哈希验证测试
 * 
 * 用于验证 APP_TEST_DATA.sql 中的密码哈希是否正确
 * 
 * 使用方法：
 * 1. 复制这个文件到任意 Spring Boot 项目的 test 目录
 * 2. 运行 main 方法
 * 3. 查看输出结果
 */
public class PasswordHashTest {
    
    public static void main(String[] args) {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        
        // APP_TEST_DATA.sql 中的信息
        String rawPassword = "Test@123456";
        String sqlHash = "$2a$10$mRMIYLDtRHlf6.9ipiqH1OZUOtk5pJ7TYvKa0q5M8hC7HMQhOmOFe";
        
        System.out.println("========================================");
        System.out.println("🔐 密码哈希验证测试");
        System.out.println("========================================");
        System.out.println();
        
        // 测试 1: 验证 SQL 脚本中的哈希
        System.out.println("【测试 1】验证 SQL 脚本中的哈希");
        System.out.println("明文密码: " + rawPassword);
        System.out.println("SQL 哈希: " + sqlHash);
        boolean sqlMatches = encoder.matches(rawPassword, sqlHash);
        System.out.println("验证结果: " + (sqlMatches ? "✅ 匹配成功" : "❌ 不匹配"));
        System.out.println();
        
        // 测试 2: 生成新的哈希值
        System.out.println("【测试 2】生成新的哈希值");
        String newHash = encoder.encode(rawPassword);
        System.out.println("新哈希值: " + newHash);
        boolean newMatches = encoder.matches(rawPassword, newHash);
        System.out.println("新哈希验证: " + (newMatches ? "✅ 匹配成功" : "❌ 不匹配"));
        System.out.println();
        
        // 测试 3: 测试常见密码
        System.out.println("【测试 3】测试其他常见密码");
        String[] testPasswords = {"Test@123456", "test@123456", "TEST@123456", "123456"};
        for (String pwd : testPasswords) {
            boolean matches = encoder.matches(pwd, sqlHash);
            System.out.println("密码: " + pwd + " -> " + (matches ? "✅ 匹配" : "❌ 不匹配"));
        }
        System.out.println();
        
        // 结论
        System.out.println("========================================");
        System.out.println("🎯 结论");
        System.out.println("========================================");
        if (sqlMatches) {
            System.out.println("✅ SQL 脚本中的密码哈希正确！");
            System.out.println("✅ 明文密码 'Test@123456' 可以成功验证");
            System.out.println();
            System.out.println("如果登录仍然失败，可能的原因：");
            System.out.println("1. 前端发送的密码不是 'Test@123456'");
            System.out.println("2. 密码在传输过程中被修改");
            System.out.println("3. 数据库中的密码哈希与 SQL 脚本不一致");
            System.out.println("4. PasswordEncoder 配置不正确");
        } else {
            System.out.println("❌ SQL 脚本中的密码哈希不正确！");
            System.out.println("❌ 需要重新生成密码哈希");
            System.out.println();
            System.out.println("请使用以下 SQL 更新密码：");
            System.out.println("UPDATE xypai_user.user SET password = '" + newHash + "' WHERE id = 2000;");
        }
        System.out.println("========================================");
    }
}

