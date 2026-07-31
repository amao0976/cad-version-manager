import axios, { AxiosInstance } from 'axios';

// 支持环境变量配置后端地址，用于 Railway 部署
const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || '/api/v1';

let authToken: string | null = localStorage.getItem('auth_token');

const api: AxiosInstance = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
});

// 请求拦截器
api.interceptors.request.use((config) => {
  if (authToken) {
    config.headers['Authorization'] = `Bearer ${authToken}`;
  }
  return config;
});

// 响应拦截器
api.interceptors.response.use(
  (response) => response,
  async (error) => {
    if (error.response?.status === 401) {
      authToken = null;
      localStorage.removeItem('auth_token');
      localStorage.removeItem('user_data');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export const apiService = {
  inspectionRequests: {
    list: (params?: any) => api.get('/inspection/requests', { params }),
    get: (id: number) => api.get(`/inspection/requests/${id}`),
    schedule: (id: number) => api.patch(`/inspection/requests/${id}/schedule`),
    complete: (id: number) => api.patch(`/inspection/requests/${id}/complete`),
    cancel: (id: number) => api.patch(`/inspection/requests/${id}/cancel`),
  },
  inspectionRecords: {
    list: (params?: any) => api.get('/inspection/records', { params }),
    get: (id: number) => api.get(`/inspection/records/${id}`),
    pending: () => api.get('/inspection/records/pending'),
    getReport: (id: number) => api.get(`/inspection/records/${id}/report`),
    createReport: (id: number) => api.post(`/inspection/records/${id}/create_report`),
  },
  inspectionReports: {
    get: (id: number) => api.get(`/inspection/reports/${id}`),
    complete: (id: number) => api.patch(`/inspection/reports/${id}/complete`),
    reopen: (id: number) => api.patch(`/inspection/reports/${id}/reopen`),
    uploadImage: (id: number, formData: FormData) =>
      api.post(`/inspection/reports/${id}/upload_image`, formData, {
        headers: { 'Content-Type': 'multipart/form-data' },
      }),
  },
  suppliers: {
    list: () => api.get('/suppliers'),
  },
  auth: {
    login: (email: string, password: string) =>
      api.post('/auth/login', { email, password }),
    logout: () => api.delete('/auth/logout'),
    me: () => api.get('/auth/me'),
  },
};

api.setAuthToken = (token: string) => {
  authToken = token;
  localStorage.setItem('auth_token', token);
};

api.getAuthToken = () => authToken;

api.clearAuthToken = () => {
  authToken = null;
  localStorage.removeItem('auth_token');
  localStorage.removeItem('user_data');
};

export default api;
