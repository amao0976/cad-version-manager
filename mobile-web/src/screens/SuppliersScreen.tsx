import React, { useState, useEffect } from 'react';
import { apiService } from '../services/api';

interface Supplier {
  id: number;
  name: string;
  contact_person: string;
  phone: string;
  email: string;
  address: string;
  category: string;
}

export default function SuppliersScreen() {
  const [suppliers, setSuppliers] = useState<Supplier[]>([]);
  const [keyword, setKeyword] = useState('');
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    loadSuppliers();
  }, []);

  const loadSuppliers = async () => {
    try {
      setIsLoading(true);
      const response = await apiService.suppliers.list();
      setSuppliers(response.data.data || response.data || []);
    } catch (error) {
      console.error('加载供应商失败:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const filteredSuppliers = suppliers.filter(s => 
    !keyword || 
    s.name.toLowerCase().includes(keyword.toLowerCase()) ||
    (s.contact_person && s.contact_person.toLowerCase().includes(keyword.toLowerCase()))
  );

  const getCategoryIcon = (category: string) => {
    const icons: Record<string, string> = {
      '材料供应商': '🧱',
      '加工厂': '🏭',
      '组装厂': '⚙️',
      '包装厂': '📦',
    };
    return icons[category] || '🏢';
  };

  if (isLoading) return <div className="loading-container"><div className="loading-spinner" /></div>;

  return (
    <div>
      <div className="search-bar">
        <input
          type="text"
          className="search-input"
          placeholder="搜索供应商名称或联系人"
          value={keyword}
          onChange={(e) => setKeyword(e.target.value)}
        />
      </div>

      <div style={{ padding: '12px' }}>
        {filteredSuppliers.length === 0 ? (
          <div className="empty-state">
            <div className="empty-state-icon">🏢</div>
            <div className="empty-state-text">暂无供应商</div>
          </div>
        ) : (
          filteredSuppliers.map(s => (
            <div key={s.id} className="list-item">
              <div className="card-header">
                <span className="card-title">{s.name}</span>
                <span style={{ fontSize: '24px' }}>{getCategoryIcon(s.category)}</span>
              </div>
              <div className="info-row"><span className="info-label">类别:</span><span className="info-value">{s.category}</span></div>
              <div className="info-row"><span className="info-label">联系人:</span><span className="info-value">{s.contact_person || 'N/A'}</span></div>
              <div className="info-row"><span className="info-label">电话:</span><span className="info-value">{s.phone || 'N/A'}</span></div>
              <div className="info-row"><span className="info-label">邮箱:</span><span className="info-value">{s.email || 'N/A'}</span></div>
              <div className="info-row"><span className="info-label">地址:</span><span className="info-value">{s.address || 'N/A'}</span></div>
            </div>
          ))
        )}
      </div>
    </div>
  );
}
