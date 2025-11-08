package com.xypai.auth.utils;

import com.xypai.auth.feign.dto.AuthUserDTO;
import org.dromara.common.core.enums.UserType;
import org.dromara.system.api.model.LoginUser;

/**
 * AuthUser → LoginUser 转换器
 * 
 * 用途: 将AuthUserDTO转换为Sa-Token需要的LoginUser格式
 * 
 * @author Alice
 * @date 2025-10-21
 */
public class AuthUserConverter {

    /**
     * 转换为LoginUser
     * 
     * @param authUser 认证用户DTO
     * @param deviceType 设备类型（web/app/mini）
     * @return LoginUser
     */
    public static LoginUser toLoginUser(AuthUserDTO authUser, String deviceType) {
        if (authUser == null) {
            return null;
        }

        LoginUser loginUser = new LoginUser();
        
        // 基础信息
        loginUser.setUserId(authUser.getId());
        loginUser.setUsername(authUser.getUsername());
        loginUser.setNickname(authUser.getNickname());
        
        // 用户类型（C端用户）
        loginUser.setUserType(UserType.APP_USER.getUserType());
        
        // 设备类型
        loginUser.setDeviceType(deviceType);
        
        // 权限信息
        loginUser.setRolePermission(authUser.getRoles());
        loginUser.setMenuPermission(authUser.getPermissions());
        
        // 登录信息（可选，在Service层设置）
        // loginUser.setIpaddr(...)
        // loginUser.setLoginLocation(...)
        
        return loginUser;
    }

    /**
     * 转换为LoginUser（带完整信息）
     * 
     * @param authUser 认证用户DTO
     * @param deviceType 设备类型
     * @param ipAddress IP地址
     * @param loginLocation 登录位置
     * @return LoginUser
     */
    public static LoginUser toLoginUserWithDetails(
            AuthUserDTO authUser, 
            String deviceType,
            String ipAddress,
            String loginLocation) {
        
        LoginUser loginUser = toLoginUser(authUser, deviceType);
        
        if (loginUser != null) {
            loginUser.setIpaddr(ipAddress);
            loginUser.setLoginLocation(loginLocation);
        }
        
        return loginUser;
    }
}

/*
 * ==========================================
 * 使用示例
 * ==========================================
 * 
 * // 1. 基础转换
 * LoginUser loginUser = AuthUserConverter.toLoginUser(authUser, "web");
 * 
 * // 2. 带详细信息
 * LoginUser loginUser = AuthUserConverter.toLoginUserWithDetails(
 *     authUser, 
 *     "ios", 
 *     "120.244.123.45",
 *     "北京 朝阳区"
 * );
 * 
 * // 3. 在Service中使用
 * LoginUser loginUser = AuthUserConverter.toLoginUser(authUser, deviceType);
 * loginUser.setIpaddr(IpUtils.getClientIP());
 * loginUser.setLoginLocation(IpUtils.getLocationByIP(IpUtils.getClientIP()));
 * LoginHelper.login(loginUser, param);
 * 
 * ==========================================
 */

