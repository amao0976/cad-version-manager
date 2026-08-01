import React, { useState, useEffect, useCallback } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { apiService } from '../services/api';

export default function RecordDetailScreen() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [record, setRecord] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isCreatingReport, setIsCreatingReport] = useState(false);

  const loadRecord = useCallback(async () => {
    try {
      setIsLoading(true);
      const response = await apiService.inspectionRecords.get(Number(id));
      setRecord(response.data.data || response.data);
    } catch (error) {
      console.error('加载失败:', error);
    } finally {
      setIsLoading(false);
    }
  }, [id]);

  useEffect(() => { loadRecord(); }, [loadRecord]);

  const handleCreateReport = async () => {
    if (!confirm('确定要创建验货报告吗？')) return;
    try {
      setIsCreatingReport(true);
      const response = await apiService.inspectionRecords.createReport(Number(id));
      const reportId = response.data.data?.id;
      if (reportId) navigate(`/reports/${reportId}`);
    } catch (error: any) {
      alert(error.response?.data?.error || '创建失败');
    } finally {
      setIsCreatingReport(false);
    }
  };

  const handleViewReport = async () => {
    try {
      const response = await apiService.inspectionRecords.getReport(Number(id));
      const reportId = response.data.data?.id;
      if (reportId) {
        navigate(`/reports/${reportId}`);
      } else {
        alert('报告数据异常');
      }
    } catch (error: any) {
      alert(error.response?.data?.error || '获取报告失败');
    }
  };

  if (isLoading) return <div className="loading-container"><div className="loading-spinner" /></div>;
  if (!record) return <div className="empty-state"><div className="empty-state-text">未找到验货记录</div></div>;

  const resultColor = !record.result ? '#6b7280' : record.result === 'pass' ? '#16a34a' : '#dc2626';
  const resultLabel = !record.result ? '待检验' : record.result === 'pass' ? '合格' : '不合格';

  return (
    <div>
      <div style={{ padding: '12px', display: 'flex', gap: '8px' }}>
        <button className="btn btn-secondary" onClick={() => navigate(-1)}>← 返回</button>
      </div>

      <div style={{ padding: '12px' }}>
        <div className="card">
          <div className="card-header">
            <span className="card-title">{record.order_no}</span>
            <span className="badge" style={{ background: resultColor }}>{resultLabel}</span>
          </div>
          {record.has_report ? (
            <button
              className="btn btn-primary btn-block"
              onClick={handleViewReport}
              style={{ marginTop: '10px' }}
            >
              📄 查看验货报告
            </button>
          ) : (
            <button
              className="btn btn-primary btn-block"
              onClick={handleCreateReport}
              disabled={isCreatingReport}
              style={{ marginTop: '10px' }}
            >
              {isCreatingReport ? '创建中...' : '创建验货报告（可选）'}
            </button>
          )}
        </div>

        <div className="card">
          <div className="section-title">基本信息</div>
          <div className="info-row"><span className="info-label">订单号:</span><span className="info-value">{record.order_no}</span></div>
          <div className="info-row"><span className="info-label">参考号:</span><span className="info-value">{record.reference_no || 'N/A'}</span></div>
          <div className="info-row"><span className="info-label">验货类型:</span><span className="info-value">{record.inspection_type}</span></div>
          <div className="info-row"><span className="info-label">验货日期:</span><span className="info-value">{new Date(record.inspection_date).toLocaleDateString()}</span></div>
        </div>

        <div className="card">
          <div className="section-title">数量统计</div>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '10px' }}>
            <div style={{ background: '#f9fafb', padding: '12px', borderRadius: '8px', textAlign: 'center' }}>
              <div style={{ fontSize: '12px', color: '#666' }}>订单数量</div>
              <div style={{ fontSize: '22px', fontWeight: 'bold' }}>{record.order_quantity}</div>
            </div>
            <div style={{ background: '#f9fafb', padding: '12px', borderRadius: '8px', textAlign: 'center' }}>
              <div style={{ fontSize: '12px', color: '#666' }}>出货数量</div>
              <div style={{ fontSize: '22px', fontWeight: 'bold' }}>{record.shipment_quantity}</div>
            </div>
            <div style={{ background: '#fef3c7', padding: '12px', borderRadius: '8px', textAlign: 'center' }}>
              <div style={{ fontSize: '12px', color: '#666' }}>大缺陷</div>
              <div style={{ fontSize: '22px', fontWeight: 'bold', color: '#d97706' }}>{record.major_defects}</div>
            </div>
            <div style={{ background: '#fee2e2', padding: '12px', borderRadius: '8px', textAlign: 'center' }}>
              <div style={{ fontSize: '12px', color: '#666' }}>小缺陷</div>
              <div style={{ fontSize: '22px', fontWeight: 'bold', color: '#dc2626' }}>{record.minor_defects}</div>
            </div>
          </div>
        </div>

        {record.product && (
          <div className="card">
            <div className="section-title">产品信息</div>
            <div className="info-row"><span className="info-label">名称:</span><span className="info-value">{record.product.name}</span></div>
            <div className="info-row"><span className="info-label">编码:</span><span className="info-value">{record.product.product_code}</span></div>
          </div>
        )}

        {record.comments && (
          <div className="card">
            <div className="section-title">备注</div>
            <p style={{ color: '#666', fontSize: '14px', lineHeight: '20px' }}>{record.comments}</p>
          </div>
        )}
      </div>
    </div>
  );
}
