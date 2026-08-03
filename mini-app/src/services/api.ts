import Taro from '@tarojs/taro';
import type { ApiResponse } from '../types';

// 后端API地址 - 1Panel部署后改成你的域名
// 示例：https://cad.example.com/api/v1
const API_BASE_URL = 'https://cad-version-manager-production.up.railway.app/api/v1';

// 获取存储的token
function getToken(): string | null {
  return Taro.getStorageSync('auth_token') || null;
}

// 设置token
function setToken(token: string) {
  Taro.setStorageSync('auth_token', token);
}

// 清除token
function clearToken() {
  Taro.removeStorageSync('auth_token');
  Taro.removeStorageSync('user_data');
}

// 封装请求
async function request<T = any>(
  method: 'GET' | 'POST' | 'PATCH' | 'DELETE',
  url: string,
  data?: any
): Promise<T> {
  const token = getToken();
  const header: Record<string, string> = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  if (token) {
    header['Authorization'] = `Bearer ${token}`;
  }

  try {
    const res = await Taro.request({
      url: `${API_BASE_URL}${url}`,
      method,
      data,
      header,
      timeout: 15000,
    });

    if (res.statusCode === 401 && url !== '/auth/login') {
      clearToken();
      Taro.reLaunch({ url: '/pages/login/index' });
      throw new Error('登录已过期，请重新登录');
    }

    if (res.statusCode >= 400) {
      const errMsg = res.data?.error || res.data?.message || `请求失败 (${res.statusCode})`;
      console.error(`[API] ${method} ${url} 错误:`, errMsg);
      throw new Error(errMsg);
    }

    return res.data as T;
  } catch (error) {
    console.error(`[API] ${method} ${url} 异常:`, error);
    if (error instanceof Error && error.message) {
      throw error;
    }
    const errMsg = (error as any)?.errMsg || (error as any)?.message || '网络请求失败，请检查网络连接';
    throw new Error(errMsg);
  }
}

// 封装文件上传
async function uploadFile(url: string, filePath: string, formData?: Record<string, string>) {
  const token = getToken();
  const header: Record<string, string> = {};
  if (token) {
    header['Authorization'] = `Bearer ${token}`;
  }

  try {
    const res = await Taro.uploadFile({
      url: `${API_BASE_URL}${url}`,
      filePath,
      name: 'image',
      formData,
      header,
    });

    if (res.statusCode >= 400) {
      const data = JSON.parse(res.data);
      throw new Error(data?.error || '上传失败');
    }

    return JSON.parse(res.data);
  } catch (error) {
    console.error(`[API] upload ${url} 异常:`, error);
    throw error;
  }
}

export const apiService = {
  auth: {
    login: (email: string, password: string) =>
      request<{ token: string; data: any }>('POST', '/auth/login', { email, password }),
    logout: () => request('DELETE', '/auth/logout'),
    me: () => request('GET', '/auth/me'),
  },
  inspectionRequests: {
    list: (params?: Record<string, any>) =>
      request<ApiResponse<any[]>>('GET', '/inspection/requests', params),
    get: (id: number) =>
      request<ApiResponse<any>>('GET', `/inspection/requests/${id}`),
    create: (data: any) =>
      request('POST', '/inspection/requests', { inspection_request: data }),
    newOptions: () =>
      request<ApiResponse<any>>('GET', '/inspection/requests/new_options'),
    schedule: (id: number) =>
      request<ApiResponse<any>>('PATCH', `/inspection/requests/${id}/schedule`),
    cancel: (id: number) =>
      request<ApiResponse<any>>('PATCH', `/inspection/requests/${id}/cancel`),
  },
  inspectionRecords: {
    list: (params?: Record<string, any>) =>
      request<ApiResponse<any[]>>('GET', '/inspection/records', params),
    get: (id: number) =>
      request<ApiResponse<any>>('GET', `/inspection/records/${id}`),
    update: (id: number, data: any) =>
      request('PATCH', `/inspection/records/${id}`, { inspection_record: data }),
    create: (data: any) =>
      request('POST', '/inspection/records', { inspection_record: data }),
    newOptions: () =>
      request<ApiResponse<any>>('GET', '/inspection/records/new_options'),
    createReport: (id: number) =>
      request('POST', `/inspection/records/${id}/create_report`),
    getReport: (id: number) =>
      request<ApiResponse<any>>('GET', `/inspection/records/${id}/report`),
  },
  inspectionReports: {
    get: (id: number) =>
      request<ApiResponse<any>>('GET', `/inspection/reports/${id}`),
    complete: (id: number) =>
      request('PATCH', `/inspection/reports/${id}/complete`),
    uploadImage: (id: number, filePath: string, category: string) =>
      uploadFile(`/inspection/reports/${id}/upload_image`, filePath, { category }),
    removeImage: (id: number, attachmentId: number) =>
      request('DELETE', `/inspection/reports/${id}/remove_image`, { attachment_id: attachmentId }),
  },
  suppliers: {
    list: () => request<ApiResponse<any[]>>('GET', '/suppliers'),
  },
};

export { setToken, clearToken, getToken };
