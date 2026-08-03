import Taro from '@tarojs/taro';
import { createContext, useContext } from 'react';
import { apiService, setToken, clearToken } from '../services/api';
import type { User } from '../types';

interface AuthStore {
  user: User | null;
  isAuthenticated: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
  loadUser: () => void;
}

const AuthContext = createContext<AuthStore | undefined>(undefined);

export function getStoredUser(): User | null {
  const userDataStr = Taro.getStorageSync('user_data');
  if (!userDataStr) return null;
  try {
    return JSON.parse(userDataStr);
  } catch {
    return null;
  }
}

export function isUserLoggedIn(): boolean {
  return !!Taro.getStorageSync('auth_token');
}

export function authLogin(email: string, password: string): Promise<void> {
  return apiService.auth.login(email, password).then((res) => {
    const { token, data } = res;
    const user: User = {
      id: data.id,
      email: data.email,
      name: data.name,
      role: data.role,
      token,
    };
    setToken(token);
    Taro.setStorageSync('user_data', JSON.stringify(user));
  });
}

export async function authLogout() {
  try {
    await apiService.auth.logout();
  } catch {
    // 忽略登出API错误
  }
  clearToken();
}

export { AuthContext };
