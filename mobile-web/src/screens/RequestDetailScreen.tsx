import React, { useState, useEffect, useCallback } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { apiService } from '../services/api';

export default function RequestDetailScreen() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [request, setRequest] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(true);

  const loadRequest = useCallback(async () => {
    try {
      setIsLoading(true);
      const response = await apiService.inspectionRequests.get(Number(id));
      setRequest(response.data.data || response.data);
    } catch (error) {
      console.error('加载失败:', error);
    } finally {
      setIsLoading(false);
    }
  }, [id]);

  useEffect(() => { loadRequest(); }, [loadRequest]);

  const handleAction = async (action: 'schedule' | 'complete' | 'cancel') => {
    if (!confirm(`确定要${action === 'schedule' ? '排期' : action === 'complete' ? '完成' : '取消'}此验货申请吗？`)) return;
    try {
      await apiService.inspectionRequests[action](Number(id));
      alert('操作成功');
      loadRequest();
    } catch (error: any) {
      alert(error.response?.data?.error || '操作失败');
    }
  };

  if (isLoading) return <div className="loading-container"><div className="loading-spinner" /></div>;
  if (!request) return <div className="empty-state"><div className="empty-state-text">未找到验货申请</div></div>;

  return (
    <div>
      <div style={{ padding: '12px', display: 'flex', alignItems: 'center', gap: '8px' }}>
        <button className="btn btn-secondary" onClick={() => navigate(-1)}>← 返回</button>
      </div>

      <div style={{ padding: '12px' }}>
        <div className="card">
          <div className="card-header">
            <span className="card-title">{request.order_number}</span>
            <span className={`badge badge-${request.status}`}>{request.status_label}</span>
          </div>
        </div>

        <div className="card">
          <div className="section-title">基本信息</div>
          <div className="info-row"><span className="info-label">订单号:</span><span className="info-value">{request.order_number}</span></div>
          <div className="info-row"><span className="info-label">款号:</span><span className="info-value">{request.style_number}</span></div>
          <div className="info-row"><span className="info-label">数量:</span><span className="info-value">{request.quantity}</span></div>
          <div className="info-row"><span className="info-label">验货类型:</span><span className="info-value">{request.inspection_type}</span></div>
          <div className="info-row"><span className="info-label">申请日期:</span><span className="info-value">{new Date(request.requested_date).toLocaleDateString()}</span></div>
          <div className="info-row"><span className="info-label">供应商:</span><span className="info-value">{request.supplier?.name || 'N/A'}</span></div>
          <div className="info-row"><span className="info-label">产品:</span><span className="info-value">{request.product?.name || 'N/A'}</span></div>
        </div>

        {request.items && request.items.length > 0 && (
          <div className="card">
            <div className="section-title">验货明细</div>
            {request.items.map((item: any) => (
              <div key={item.id} style={{ background: '#f9fafb', padding: '10px', borderRadius: '8px', marginBottom: '8px' }}>
                <div className="info-row"><span className="info-label">订单号:</span><span className="info-value">{item.order_number}</span></div>
                <div className="info-row"><span className="info-label">款号:</span><span className="info-value">{item.style_number}</span></div>
                <div className="info-row"><span className="info-label">数量:</span><span className="info-value">{item.quantity}</span></div>
                <div className="info-row"><span className="info-label">检验水平:</span><span className="info-value">{item.inspection_level}</span></div>
                <div className="info-row"><span className="info-label">AQL:</span><span className="info-value">{item.aql_level}</span></div>
              </div>
            ))}
          </div>
        )}

        {request.remarks && (
          <div className="card">
            <div className="section-title">备注</div>
            <p style={{ color: '#666', fontSize: '14px', lineHeight: '20px' }}>{request.remarks}</p>
          </div>
        )}
      </div>

      <div className="action-bar">
        {request.can_schedule && <button className="btn btn-warning" onClick={() => handleAction('schedule')}>排期</button>}
        {request.can_complete && <button className="btn btn-success" onClick={() => handleAction('complete')}>完成</button>}
        {request.can_cancel && <button className="btn btn-danger" onClick={() => handleAction('cancel')}>取消</button>}
        {request.status === 'scheduled' && <button className="btn btn-primary" onClick={() => navigate(`/records/new?request_id=${request.id}`)}>创建验货记录</button>}
      </div>
    </div>
  );
}
