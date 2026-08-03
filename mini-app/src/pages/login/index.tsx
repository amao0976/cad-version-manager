import React, { useState } from 'react';
import { View, Text, Input, Button } from '@tarojs/components';
import Taro from '@tarojs/taro';
import { authLogin } from '../../store/auth';
import styles from './index.module.scss';

function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleLogin = async () => {
    if (!email.trim()) {
      setError('请输入邮箱');
      return;
    }
    if (!password.trim()) {
      setError('请输入密码');
      return;
    }

    setError('');
    setLoading(true);
    try {
      await authLogin(email.trim(), password);
      Taro.showToast({ title: '登录成功', icon: 'success' });
      setTimeout(() => {
        Taro.switchTab({ url: '/pages/requests/index' });
      }, 500);
    } catch (err: any) {
      console.error('[登录失败]', err);
      const msg = err?.message || err?.errMsg || '';
      if (msg.includes('request:fail') || msg.includes('fail')) {
        setError('网络连接失败，请在开发者工具中勾选"不校验合法域名"');
      } else {
        setError(msg || '登录失败，请检查邮箱和密码');
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <View className={styles.page}>
      <View className={styles.logo}>
        <View className={styles.logoIcon}>
          <Text>🔍</Text>
        </View>
        <Text className={styles.logoText}>验货管理系统</Text>
      </View>
      <View className={styles.form}>
        <View className={styles.field}>
          <Text className={styles.label}>邮箱</Text>
          <Input
            className={styles.input}
            placeholder="请输入邮箱"
            value={email}
            onInput={(e) => setEmail(e.detail.value)}
            type="text"
          />
        </View>
        <View className={styles.field}>
          <Text className={styles.label}>密码</Text>
          <Input
            className={styles.input}
            placeholder="请输入密码"
            value={password}
            onInput={(e) => setPassword(e.detail.value)}
            password
          />
        </View>
        {error && <Text className={styles.errorText}>{error}</Text>}
        <Button
          className={styles.submitBtn}
          onClick={handleLogin}
          loading={loading}
          disabled={loading}
        >
          {loading ? '登录中...' : '登录'}
        </Button>
      </View>
      <Text className={styles.hint}>
        测试账号: admin@example.com / password123{'\n'}QC账号: qc@example.com / password123
      </Text>
    </View>
  );
}

export default LoginPage;
