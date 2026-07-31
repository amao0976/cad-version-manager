import axios, { AxiosInstance, AxiosRequestConfig, InternalAxiosRequestConfig } from 'axios';
import { getItem, deleteItem } from './storage';

const API_BASE_URL = 'http://localhost:3000/api/v1';

let authToken: string | null = null;

const api: AxiosInstance = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
});

// 请求拦截器：添加认证 token
api.interceptors.request.use(
  async (config: InternalAxiosRequestConfig) => {
    try {
      // 优先使用内存中的 token，如果没有则从存储中读取
      let token = authToken;
      if (!token) {
        token = await getItem('auth_token');
      }
      
      if (token) {
        config.headers['Authorization'] = `Bearer ${token}`;
      }
    } catch (error) {
      console.error('获取认证信息失败:', error);
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// 响应拦截器：处理错误
api.interceptors.response.use(
  (response) => {
    return response;
  },
  async (error) => {
    if (error.response?.status === 401) {
      // Token 过期，清除本地存储
      authToken = null;
      await deleteItem('auth_token');
      await deleteItem('user_data');
      // 这里可以触发重新登录
    }
    return Promise.reject(error);
  }
);

// API 辅助方法
export const apiService = {
  // 验货申请 API
  inspectionRequests: {
    list: (params?: { status?: string; keyword?: string; page?: number }) =>
      api.get('/inspection/requests', { params }),
    get: (id: number) => api.get(`/inspection/requests/${id}`),
    schedule: (id: number) => api.patch(`/inspection/requests/${id}/schedule`),
    complete: (id: number) => api.patch(`/inspection/requests/${id}/complete`),
    cancel: (id: number) => api.patch(`/inspection/requests/${id}/cancel`),
  },

  // 验货记录 API
  inspectionRecords: {
    list: (params?: { result?: string; keyword?: string; page?: number }) =>
      api.get('/inspection/records', { params }),
    get: (id: number) => api.get(`/inspection/records/${id}`),
    pending: () => api.get('/inspection/records/pending'),
    getReport: (id: number) => api.get(`/inspection/records/${id}/report`),
    createReport: (id: number) => api.post(`/inspection/records/${id}/create_report`),
  },

  // 验货报告 API
  inspectionReports: {
    get: (id: number) => api.get(`/inspection/reports/${id}`),
    complete: (id: number) => api.patch(`/inspection/reports/${id}/complete`),
    reopen: (id: number) => api.patch(`/inspection/reports/${id}/reopen`),
    uploadImage: (id: number, imageUri: string, category: string) => {
      const formData = new FormData();
      formData.append('image', {
        uri: imageUri,
        name: `inspection_${Date.now()}.jpg`,
        type: 'image/jpeg',
      } as any);
      formData.append('category', category);
      return api.post(`/inspection/reports/${id}/upload_image`, formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      });
    },
    removeImage: (id: number, attachmentId: number) =>
      api.delete(`/inspection/reports/${id}/remove_image`, {
        params: { attachment_id: attachmentId },
      }),
  },

  // 供应商 API
  suppliers: {
    list: (params?: { keyword?: string }) => api.get('/suppliers', { params }),
    get: (id: number) => api.get(`/suppliers/${id}`),
  },
};

// Token 管理方法
api.setAuthToken = (token: string) => {
  authToken = token;
};

api.getAuthToken = () => authToken;

api.clearAuthToken = () => {
  authToken = null;
};

export default api;
