import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import api from '../services/api';
import { saveItem, getItem, deleteItem } from '../services/storage';

interface User {
  id: number;
  email: string;
  name: string;
  role: string;
  token: string;
}

interface AuthContextType {
  user: User | null;
  isLoading: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
  isAuthenticated: boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    loadUser();
  }, []);

  const loadUser = async () => {
    try {
      const token = await getItem('auth_token');
      const userDataStr = await getItem('user_data');
      
      if (token && userDataStr) {
        const parsedUser = JSON.parse(userDataStr);
        api.setAuthToken(token);
        setUser({ ...parsedUser, token });
      }
    } catch (error) {
      console.error('加载用户信息失败:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const login = async (email: string, password: string) => {
    setIsLoading(true);
    try {
      const response = await api.post('/auth/login', {
        email,
        password,
      });

      const { token } = response.data;
      const userData = response.data.data;

      await saveItem('auth_token', token);
      await saveItem('user_data', JSON.stringify(userData));
      await saveItem('user_email', email);

      api.setAuthToken(token);
      setUser({
        id: userData.id,
        email: userData.email,
        name: userData.name,
        role: userData.role,
        token,
      });
    } catch (error: any) {
      const message = error.response?.data?.error || '登录失败，请检查邮箱和密码';
      throw new Error(message);
    } finally {
      setIsLoading(false);
    }
  };

  const logout = async () => {
    setIsLoading(true);
    try {
      await api.delete('/auth/logout');
    } catch (error) {
      // 即使服务器端登出失败，也要清除本地存储
    }
    
    await deleteItem('auth_token');
    await deleteItem('user_data');
    api.clearAuthToken();
    setUser(null);
    setIsLoading(false);
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        isLoading,
        login,
        logout,
        isAuthenticated: !!user,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}
