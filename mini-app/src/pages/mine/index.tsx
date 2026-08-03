import React from 'react';
import { View, Text } from '@tarojs/components';
import Taro, { useDidShow } from '@tarojs/taro';
import { getStoredUser, isUserLoggedIn, authLogout } from '../../store/auth';
import styles from './index.module.scss';

const ROLE_LABELS: Record<string, string> = {
  admin: '管理员',
  qc: 'QC检验员',
  engineer: '工程师',
  viewer: '查看者',
};

function MinePage() {
  const [user, setUser] = React.useState<any>(null);

  useDidShow(() => {
    if (isUserLoggedIn()) {
      setUser(getStoredUser());
    } else {
      setUser(null);
    }
  });

  const handleLogin = () => {
    Taro.navigateTo({ url: '/pages/login/index' });
  };

  const handleLogout = async () => {
    const res = await Taro.showModal({ title: '提示', content: '确定要退出登录吗？' });
    if (res.confirm) {
      await authLogout();
      setUser(null);
      Taro.reLaunch({ url: '/pages/login/index' });
    }
  };

  const handleMenu = (url: string) => {
    Taro.navigateTo({ url });
  };

  if (!user) {
    return (
      <View className={styles.page}>
        <View className={styles.header}>
          <View className={styles.avatar}>
            <Text>?</Text>
          </View>
          <Text className={styles.userName}>未登录</Text>
          <Text className={styles.userEmail}>请先登录以使用全部功能</Text>
        </View>
        <View className={styles.loginBtn} onClick={handleLogin}>
          <Text>登录</Text>
        </View>
      </View>
    );
  }

  return (
    <View className={styles.page}>
      <View className={styles.header}>
        <View className={styles.avatar}>
          <Text>{user.name?.charAt(0) || 'U'}</Text>
        </View>
        <Text className={styles.userName}>{user.name}</Text>
        <Text className={styles.userEmail}>{user.email}</Text>
        <View className={styles.roleBadge}>
          <Text>{ROLE_LABELS[user.role] || user.role}</Text>
        </View>
      </View>

      <View className={styles.menuSection}>
        <View className={styles.menuItem} onClick={() => handleMenu('/pages/create-request/index')}>
          <Text className={styles.menuIcon}>📝</Text>
          <Text className={styles.menuText}>新建验货申请</Text>
          <Text className={styles.menuArrow}>›</Text>
        </View>
        <View className={styles.menuItem} onClick={() => handleMenu('/pages/create-record/index')}>
          <Text className={styles.menuIcon}>📋</Text>
          <Text className={styles.menuText}>新建验货记录</Text>
          <Text className={styles.menuArrow}>›</Text>
        </View>
      </View>

      <View className={styles.logoutBtn} onClick={handleLogout}>
        <Text>退出登录</Text>
      </View>
    </View>
  );
}

export default MinePage;
