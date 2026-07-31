import React, { useState, useEffect, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { apiService } from '../services/api';

interface InspectionRecord {
  id: number;
  order_no: string;
  inspection_type: string;
  result: string | null;
  major_defects: number;
  minor_defects: number;
  product: { id: number; name: string } | null;
  has_report: boolean;
  created_at: string;
}

export default function RecordListScreen() {
  const navigate = useNavigate();
  const [records, setRecords] = useState<InspectionRecord[]>([]);
  const [keyword, setKeyword] = useState('');
  const [selectedResult, setSelectedResult] = useState<string | null>(null);
  const [showPendingOnly, setShowPendingOnly] = useState(false);
  const [isLoading, setIsLoading] = useState(true);

  const loadRecords = useCallback(async () => {
    try {
      setIsLoading(true);
      const response = showPendingOnly
        ? await apiService.inspectionRecords.pending()
        : await apiService.inspectionRecords.list();
      setRecords(response.data.data || response.data || []);
    } catch (error) {
      console.error('加载失败:', error);
    } finally {
      setIsLoading(false);
    }
  }, [showPendingOnly]);

  useEffect(() => { loadRecords(); }, [loadRecords]);

  const filteredRecords = records.filter(r => {
    const matchKeyword = !keyword || r.order_no.toLowerCase().includes(keyword.toLowerCase());
    const matchResult = !selectedResult || r.result === selectedResult || (selectedResult === '' && !r.result);
    return matchKeyword && matchResult;
  });

  const resultTabs = [
    { key: null, label: '全部' },
    { key: 'pass', label: '合格' },
    { key: 'fail', label: '不合格' },
    { key: '', label: '待检验' },
  ];

  const getResultBadge = (result: string | null) => {
    if (!result) return { class: 'badge-pending', label: '待检验' };
    return result === 'pass' 
      ? { class: 'badge-completed', label: '合格' }
      : { class: 'badge-cancelled', label: '不合格' };
  };

  if (isLoading) return <div className="loading-container"><div className="loading-spinner" /></div>;

  return (
    <div>
      <div className="search-bar">
        <input
          type="text"
          className="search-input"
          placeholder="搜索订单号"
          value={keyword}
          onChange={(e) => setKeyword(e.target.value)}
        />
      </div>

      <div style={{ padding: '10px 12px', display: 'flex', gap: '8px', alignItems: 'center', flexWrap: 'wrap', background: 'white', borderBottom: '1px solid #e0e0e0' }}>
        <button
          className={`status-tab ${showPendingOnly ? 'active' : ''}`}
          onClick={() => setShowPendingOnly(!showPendingOnly)}
        >
          {showPendingOnly ? '✓ ' : ''}仅显示待处理
        </button>
      </div>

      <div className="status-tabs">
        {resultTabs.map(t => (
          <button
            key={t.key || 'all'}
            className={`status-tab ${selectedResult === t.key ? 'active' : ''}`}
            onClick={() => setSelectedResult(t.key)}
          >
            {t.label}
          </button>
        ))}
      </div>

      <div style={{ padding: '12px' }}>
        {filteredRecords.length === 0 ? (
          <div className="empty-state">
            <div className="empty-state-icon">📝</div>
            <div className="empty-state-text">暂无验货记录</div>
          </div>
        ) : (
          filteredRecords.map(r => {
            const badge = getResultBadge(r.result);
            return (
              <div
                key={r.id}
                className="list-item"
                onClick={() => navigate(`/records/${r.id}`)}
              >
                <div className="card-header">
                  <span className="card-title">{r.order_no}</span>
                  <span className={`badge ${badge.class}`}>{badge.label}</span>
                </div>
                <div className="info-row"><span className="info-label">产品:</span><span className="info-value">{r.product?.name || 'N/A'}</span></div>
                <div className="info-row"><span className="info-label">类型:</span><span className="info-value">{r.inspection_type}</span></div>
                <div className="info-row">
                  <span className="info-label">缺陷:</span>
                  <span className={`info-value ${r.major_defects > 0 ? '' : ''}`} style={{ color: r.major_defects > 0 ? '#dc2626' : '#333' }}>
                    大:{r.major_defects} 小:{r.minor_defects}
                  </span>
                </div>
                {r.has_report && (
                  <div style={{ marginTop: '8px', padding: '6px 10px', background: '#dbeafe', borderRadius: '6px', display: 'inline-block', fontSize: '12px', color: '#2563EB' }}>
                    📄 已有报告
                  </div>
                )}
              </div>
            );
          })
        )}
      </div>
    </div>
  );
}
