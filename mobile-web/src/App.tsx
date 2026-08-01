import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './context/AuthContext';
import LoginScreen from './screens/LoginScreen';
import RequestListScreen from './screens/RequestListScreen';
import RequestDetailScreen from './screens/RequestDetailScreen';
import CreateRequestScreen from './screens/CreateRequestScreen';
import RecordListScreen from './screens/RecordListScreen';
import RecordDetailScreen from './screens/RecordDetailScreen';
import CreateRecordScreen from './screens/CreateRecordScreen';
import ReportScreen from './screens/ReportScreen';
import SuppliersScreen from './screens/SuppliersScreen';
import MainLayout from './components/MainLayout';

function AppRoutes() {
  const { isAuthenticated, isLoading } = useAuth();

  if (isLoading) {
    return (
      <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100vh' }}>
        <p>加载中...</p>
      </div>
    );
  }

  if (!isAuthenticated) {
    return <Routes><Route path="/login" element={<LoginScreen />} /><Route path="*" element={<Navigate to="/login" />} /></Routes>;
  }

  return (
    <Routes>
      <Route path="/login" element={<Navigate to="/" />} />
      <Route element={<MainLayout />}>
        <Route path="/" element={<RequestListScreen />} />
        <Route path="/requests/new" element={<CreateRequestScreen />} />
        <Route path="/requests/:id" element={<RequestDetailScreen />} />
        <Route path="/records" element={<RecordListScreen />} />
        <Route path="/records/new" element={<CreateRecordScreen />} />
        <Route path="/records/:id" element={<RecordDetailScreen />} />
        <Route path="/reports/:id" element={<ReportScreen />} />
        <Route path="/suppliers" element={<SuppliersScreen />} />
      </Route>
      <Route path="*" element={<Navigate to="/" />} />
    </Routes>
  );
}

export default function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <AppRoutes />
      </BrowserRouter>
    </AuthProvider>
  );
}
