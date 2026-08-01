import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { apiService } from '../services/api';

interface Option {
  id: number;
  name: string;
}

interface ItemForm {
  order_number: string;
  style_number: string;
  quantity: string;
  inspection_level: string;
  aql_level: string;
}

export default function CreateRequestScreen() {
  const navigate = useNavigate();
  const [options, setOptions] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [error, setError] = useState('');

  const [supplierId, setSupplierId] = useState('');
  const [productId, setProductId] = useState('');
  const [inspectionType, setInspectionType] = useState('中期检查');
  const [requestedDate, setRequestedDate] = useState(new Date().toISOString().split('T')[0]);
  const [remarks, setRemarks] = useState('');
  const [items, setItems] = useState<ItemForm[]>([
    { order_number: '', style_number: '', quantity: '', inspection_level: 'II', aql_level: '2.5' },
  ]);

  useEffect(() => { loadOptions(); }, []);

  const loadOptions = async () => {
    try {
      const response = await apiService.inspectionRequests.newOptions();
      setOptions(response.data.data);
    } catch (err) {
      setError('加载选项数据失败');
    } finally {
      setIsLoading(false);
    }
  };

  const addItem = () => {
    setItems([...items, { order_number: '', style_number: '', quantity: '', inspection_level: 'II', aql_level: '2.5' }]);
  };

  const removeItem = (index: number) => {
    if (items.length > 1) setItems(items.filter((_, i) => i !== index));
  };

  const updateItem = (index: number, field: keyof ItemForm, value: string) => {
    const updated = [...items];
    updated[index] = { ...updated[index], [field]: value };
    setItems(updated);
  };

  const handleSubmit = async () => {
    setError('');
    if (!supplierId) { setError('请选择供应商'); return; }
    if (!requestedDate) { setError('请选择申请日期'); return; }

    for (const item of items) {
      if (!item.order_number || !item.style_number || !item.quantity) {
        setError('请填写完整的明细项（订单号、款号、数量）');
        return;
      }
    }

    try {
      setIsSaving(true);
      const data = {
        supplier_id: supplierId,
        product_id: productId || undefined,
        inspection_type: inspectionType,
        requested_date: requestedDate,
        remarks: remarks || undefined,
        items_attributes: items.map(i => ({
          order_number: i.order_number,
          style_number: i.style_number,
          quantity: parseInt(i.quantity),
          inspection_level: i.inspection_level,
          aql_level: i.aql_level,
        })),
      };
      await apiService.inspectionRequests.create(data);
      alert('验货申请创建成功');
      navigate('/');
    } catch (err: any) {
      setError(err.response?.data?.error || '创建失败');
    } finally {
      setIsSaving(false);
    }
  };

  if (isLoading) return <div className="loading-container"><div className="loading-spinner" /></div>;

  return (
    <div>
      <div style={{ padding: '12px', display: 'flex', gap: '8px' }}>
        <button className="btn btn-secondary" onClick={() => navigate(-1)}>← 返回</button>
        <h2 style={{ flex: 1, fontSize: '18px', fontWeight: 600 }}>新建验货申请</h2>
      </div>

      {error && <div style={{ margin: '0 12px 12px', background: '#fee2e2', color: '#dc2626', padding: '10px', borderRadius: '8px', fontSize: '14px' }}>{error}</div>}

      <div style={{ padding: '12px' }}>
        <div className="card">
          <div className="section-title">基本信息</div>

          <div className="form-group">
            <label className="form-label">供应商 *</label>
            <select className="form-input" value={supplierId} onChange={(e) => setSupplierId(e.target.value)}>
              <option value="">请选择供应商</option>
              {options?.suppliers?.map((s: Option) => <option key={s.id} value={s.id}>{s.name}</option>)}
            </select>
          </div>

          <div className="form-group">
            <label className="form-label">产品（可选）</label>
            <select className="form-input" value={productId} onChange={(e) => setProductId(e.target.value)}>
              <option value="">请选择产品</option>
              {options?.products?.map((p: Option) => <option key={p.id} value={p.id}>{p.name}</option>)}
            </select>
          </div>

          <div className="form-group">
            <label className="form-label">验货类型 *</label>
            <select className="form-input" value={inspectionType} onChange={(e) => setInspectionType(e.target.value)}>
              {options?.inspection_types?.map((t: string) => <option key={t} value={t}>{t}</option>)}
            </select>
          </div>

          <div className="form-group">
            <label className="form-label">申请日期 *</label>
            <input type="date" className="form-input" value={requestedDate} onChange={(e) => setRequestedDate(e.target.value)} />
          </div>

          <div className="form-group">
            <label className="form-label">备注</label>
            <textarea className="form-input" style={{ minHeight: '60px', resize: 'vertical' }} value={remarks} onChange={(e) => setRemarks(e.target.value)} placeholder="备注信息..." />
          </div>
        </div>

        <div className="card">
          <div className="section-title">验货明细</div>
          {items.map((item, idx) => (
            <div key={idx} style={{ background: '#f9fafb', padding: '12px', borderRadius: '8px', marginBottom: '12px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '8px' }}>
                <span style={{ fontWeight: 600, fontSize: '14px' }}>明细 {idx + 1}</span>
                {items.length > 1 && <button className="btn btn-danger" style={{ padding: '4px 10px', fontSize: '12px' }} onClick={() => removeItem(idx)}>删除</button>}
              </div>

              <div className="form-group">
                <label className="form-label">订单号 *</label>
                <input className="form-input" value={item.order_number} onChange={(e) => updateItem(idx, 'order_number', e.target.value)} placeholder="订单号" />
              </div>
              <div className="form-group">
                <label className="form-label">款号 *</label>
                <input className="form-input" value={item.style_number} onChange={(e) => updateItem(idx, 'style_number', e.target.value)} placeholder="款号" />
              </div>
              <div className="form-group">
                <label className="form-label">数量 *</label>
                <input type="number" className="form-input" value={item.quantity} onChange={(e) => updateItem(idx, 'quantity', e.target.value)} placeholder="数量" />
              </div>
              <div className="form-group">
                <label className="form-label">检验水平</label>
                <select className="form-input" value={item.inspection_level} onChange={(e) => updateItem(idx, 'inspection_level', e.target.value)}>
                  {options?.inspection_levels?.map((l: any) => <option key={l.value} value={l.value}>{l.label}</option>)}
                </select>
              </div>
              <div className="form-group">
                <label className="form-label">AQL</label>
                <select className="form-input" value={item.aql_level} onChange={(e) => updateItem(idx, 'aql_level', e.target.value)}>
                  {options?.aql_levels?.map((a: string) => <option key={a} value={a}>{a}</option>)}
                </select>
              </div>
            </div>
          ))}
          <button className="btn btn-secondary btn-block" onClick={addItem}>+ 添加明细</button>
        </div>
      </div>

      <div className="action-bar">
        <button className="btn btn-primary btn-block" onClick={handleSubmit} disabled={isSaving}>
          {isSaving ? '提交中...' : '提交申请'}
        </button>
      </div>
    </div>
  );
}
