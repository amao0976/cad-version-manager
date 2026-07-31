import React, { createContext, useContext, useState, ReactNode, useCallback } from 'react';
import { apiService } from '../services/api';
import type { InspectionRequest, InspectionRecord, InspectionReport, Supplier } from '../types';

interface ApiContextType {
  requests: InspectionRequest[];
  records: InspectionRecord[];
  reports: InspectionReport[];
  suppliers: Supplier[];
  isLoading: boolean;
  error: string | null;
  fetchRequests: (params?: { status?: string; keyword?: string }) => Promise<void>;
  fetchRecords: (params?: { result?: string; keyword?: string }) => Promise<void>;
  fetchReports: () => Promise<void>;
  fetchSuppliers: () => Promise<void>;
}

const ApiContext = createContext<ApiContextType | undefined>(undefined);

export function ApiProvider({ children }: { children: ReactNode }) {
  const [requests, setRequests] = useState<InspectionRequest[]>([]);
  const [records, setRecords] = useState<InspectionRecord[]>([]);
  const [reports, setReports] = useState<InspectionReport[]>([]);
  const [suppliers, setSuppliers] = useState<Supplier[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const fetchRequests = useCallback(async (params?: { status?: string; keyword?: string }) => {
    try {
      setIsLoading(true);
      setError(null);
      const response = await apiService.inspectionRequests.list(params);
      setRequests(response.data?.data || response.data || []);
    } catch (err: any) {
      setError(err.message || '加载失败');
    } finally {
      setIsLoading(false);
    }
  }, []);

  const fetchRecords = useCallback(async (params?: { result?: string; keyword?: string }) => {
    try {
      setIsLoading(true);
      setError(null);
      const response = await apiService.inspectionRecords.list(params);
      setRecords(response.data?.data || response.data || []);
    } catch (err: any) {
      setError(err.message || '加载失败');
    } finally {
      setIsLoading(false);
    }
  }, []);

  const fetchReports = useCallback(async () => {
    try {
      setIsLoading(true);
      setError(null);
      setReports([]); // Reports are typically fetched individually
    } catch (err: any) {
      setError(err.message || '加载失败');
    } finally {
      setIsLoading(false);
    }
  }, []);

  const fetchSuppliers = useCallback(async () => {
    try {
      setIsLoading(true);
      setError(null);
      const response = await apiService.suppliers.list();
      setSuppliers(response.data?.data || response.data || []);
    } catch (err: any) {
      setError(err.message || '加载失败');
    } finally {
      setIsLoading(false);
    }
  }, []);

  return (
    <ApiContext.Provider
      value={{
        requests,
        records,
        reports,
        suppliers,
        isLoading,
        error,
        fetchRequests,
        fetchRecords,
        fetchReports,
        fetchSuppliers,
      }}
    >
      {children}
    </ApiContext.Provider>
  );
}

export function useApi() {
  const context = useContext(ApiContext);
  if (!context) {
    throw new Error('useApi must be used within an ApiProvider');
  }
  return context;
}
