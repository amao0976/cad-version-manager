import { Platform } from 'react-native';
import * as SecureStore from 'expo-secure-store';

// 跨平台存储封装
// 在 Web 上使用 localStorage，在原生平台上使用 SecureStore

const isWeb = Platform.OS === 'web';

export async function saveItem(key: string, value: string): Promise<void> {
  try {
    if (isWeb) {
      localStorage.setItem(key, value);
    } else {
      await SecureStore.setItemAsync(key, value);
    }
  } catch (error) {
    console.error(`存储 ${key} 失败:`, error);
  }
}

export async function getItem(key: string): Promise<string | null> {
  try {
    if (isWeb) {
      return localStorage.getItem(key);
    } else {
      return await SecureStore.getItemAsync(key);
    }
  } catch (error) {
    console.error(`获取 ${key} 失败:`, error);
    return null;
  }
}

export async function deleteItem(key: string): Promise<void> {
  try {
    if (isWeb) {
      localStorage.removeItem(key);
    } else {
      await SecureStore.deleteItemAsync(key);
    }
  } catch (error) {
    console.error(`删除 ${key} 失败:`, error);
  }
}
