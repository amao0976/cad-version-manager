import React, { useState, useEffect, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { apiService } from '../services/api';

interface InspectionRequest {
  id: number;
  order_number: string;
  style_number: string;
  quantity: number;
  status: string;
  status_label: string;
  inspection_type: string;
  requested_date: string;
  supplier: { id: number; name: string } | null;
  can_schedule: boolean;
  can_complete: boolean;
  can_cancel: boolean;
}

export default function RequestListScreen() {
  const navigate = useNavigate();
  const [requests, setRequests] = useState<InspectionRequest[]>([]);
  const [keyword, setKeyword] = useState('');
  const [selectedStatus, setSelectedStatus] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  const loadRequests = useCallback(async () => {
    try {
      setIsLoading(true);
      const response = await apiService.inspectionRequests.list();
      setRequests(response.data.data || response.data || []);
    } catch (error) {
      console.error('加载验货申请失败:', error);
    } finally {
      setIsLoading(false);
    }
  }, []);

  useEffect(() => { loadRequests(); }, [loadRequests]);

  const filteredRequests = requests.filter(r => {
    const matchKeyword = !keyword || 
      r.order_number.toLowerCase().includes(keyword.toLowerCase()) ||
      (r.style_number && r.style_number.toLowerCase().includes(keyword.toLowerCase()));
    const matchStatus = !selectedStatus || r.status === selectedStatus;
    return matchKeyword && matchStatus;
  });

  const statuses = [
    { key: null, label: '全部' },
    { key: 'pending', label: '待处理' },
    { key: 'scheduled', label: '已排期' },
    { key: 'cancelled', label: '已取消' },
  ];

  if (isLoading) {
    return <div className="loading-container"><div className="loading-spinner" /></div>;
  }

  return (
    <div>
      <div className="search-bar">
        <input
          type="text"
          className="search-input"
          placeholder="搜索订单号或款号"
          value={keyword}
          onChange={(e) => setKeyword(e.target.value)}
        />
      </div>

      <div style={{ padding: '0 12px 8px' }}>
        <button className="btn btn-primary btn-block" onClick={() => navigate('/requests/new')}>
          + 新建验货申请
        </button>
      </div>

      <div className="status-tabs">
        {statuses.map(s => (
          <button
            key={s.key || 'all'}
            className={`status-tab ${selectedStatus === s.key ? 'active' : ''}`}
            onClick={() => setSelectedStatus(s.key)}
          >
            {s.label}
          </button>
        ))}
      </div>

      <div style={{ padding: '12px' }}>
        {filteredRequests.length === 0 ? (
          <div className="empty-state">
            <div className="empty-state-icon">📋</div>
            <div className="empty-state-text">暂无验货申请</div>
          </div>
        ) : (
          filteredRequests.map(r => (
            <div
              key={r.id}
              className="list-item"
              onClick={() => navigate(`/requests/${r.id}`)}
            >
              <div className="card-header">
                <span className="card-title">{r.order_number}</span>
                <span className={`badge badge-${r.status}`}>{r.status_label}</span>
              </div>
              <div className="info-row"><span className="info-label">款号:</span><span className="info-value">{r.style_number || 'N/A'}</span></div>
              <div className="info-row"><span className="info-label">数量:</span><span className="info-value">{r.quantity}</span></div>
              <div className="info-row"><span className="info-label">类型:</span><span className="info-value">{r.inspection_type}</span></div>
              <div className="info-row"><span className="info-label">供应商:</span><span className="info-value">{r.supplier?.name || 'N/A'}</span></div>
              <div className="info-row"><span className="info-label">日期:</span><span className="info-value">{new Date(r.requested_date).toLocaleDateString()}</span></div>
            </div>
          ))
        )}
      </div>
    </div>
  );
}
