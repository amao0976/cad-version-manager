import Taro from '@tarojs/taro';
import type { ApiResponse } from '../types';

const API_BASE_URL = 'https://cad-version-manager-production.up.railway.app/api/v1';

function getToken(): string | null {
  return Taro.getStorageSync('auth_token') || null;
}

function setToken(token: string) {
  Taro.setStorageSync('auth_token', token);
}

function clearToken() {
  Taro.removeStorageSync('auth_token');
  Taro.removeStorageSync('user_data');
}

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

    if (res.statusCode === 401) {
      clearToken();
      Taro.reLaunch({ url: '/pages/login/index' });
      throw new Error('登录已过期，请重新登录');
    }

    if (res.statusCode >= 400) {
      const errMsg = res.data?.error || res.data?.message || `请求失败 (${res.statusCode})`;
      throw new Error(errMsg);
    }

    return res.data as T;
  } catch (error) {
    console.error(`[API] ${method} ${url} 异常:`, error);
    throw error;
  }
}

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
    calendar: (startDate: string, endDate: string) =>
      request<{ data: any[] }>('GET', '/inspection/requests/calendar', { start_date: startDate, end_date: endDate }),
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
