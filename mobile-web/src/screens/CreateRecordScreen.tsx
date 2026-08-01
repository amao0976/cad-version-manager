import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { apiService } from '../services/api';
import { useAuth } from '../context/AuthContext';

interface Option { id: number; name: string; }
interface RequestOption { id: number; order_number: string; }

export default function CreateRecordScreen() {
  const navigate = useNavigate();
  const { user } = useAuth();
  const [options, setOptions] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [error, setError] = useState('');

  const [orderNo, setOrderNo] = useState('');
  const [referenceNo, setReferenceNo] = useState('');
  const [inspectionDate, setInspectionDate] = useState(new Date().toISOString().split('T')[0]);
  const [inspectionType, setInspectionType] = useState('中期检查');
  const [supplierId, setSupplierId] = useState('');
  const [productId, setProductId] = useState('');
  const [requestId, setRequestId] = useState('');
  const [orderQty, setOrderQty] = useState('');
  const [shipmentQty, setShipmentQty] = useState('');
  const [majorDefects, setMajorDefects] = useState('0');
  const [minorDefects, setMinorDefects] = useState('0');
  const [qtyRejected, setQtyRejected] = useState('0');
  const [result, setResult] = useState('');
  const [comments, setComments] = useState('');

  useEffect(() => { loadOptions(); }, []);

  const loadOptions = async () => {
    try {
      const response = await apiService.inspectionRecords.newOptions();
      setOptions(response.data.data);
    } catch {
      setError('加载选项数据失败');
    } finally {
      setIsLoading(false);
    }
  };

  const handleSubmit = async () => {
    setError('');
    if (!orderNo) { setError('请填写订单号'); return; }
    if (!referenceNo) { setError('请填写参考号（款号）'); return; }
    if (!inspectionDate) { setError('请选择验货日期'); return; }

    try {
      setIsSaving(true);
      const data: any = {
        order_no: orderNo,
        reference_no: referenceNo,
        inspection_date: inspectionDate,
        inspection_type: inspectionType,
        order_quantity: orderQty ? parseInt(orderQty) : undefined,
        shipment_quantity: shipmentQty ? parseInt(shipmentQty) : undefined,
        major_defects: majorDefects ? parseInt(majorDefects) : 0,
        minor_defects: minorDefects ? parseInt(minorDefects) : 0,
        qty_rejected: qtyRejected ? parseInt(qtyRejected) : 0,
        result: result || undefined,
        comments: comments || undefined,
        supplier_id: supplierId || undefined,
        product_id: productId || undefined,
        inspection_request_id: requestId || undefined,
        qc_name: user?.name,
      };
      await apiService.inspectionRecords.create(data);
      alert('验货记录创建成功');
      navigate('/records');
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
        <h2 style={{ flex: 1, fontSize: '18px', fontWeight: 600 }}>新建验货记录</h2>
      </div>

      {error && <div style={{ margin: '0 12px 12px', background: '#fee2e2', color: '#dc2626', padding: '10px', borderRadius: '8px', fontSize: '14px' }}>{error}</div>}

      <div style={{ padding: '12px' }}>
        <div className="card">
          <div className="section-title">基本信息</div>

          <div className="form-group">
            <label className="form-label">关联验货申请（可选）</label>
            <select className="form-input" value={requestId} onChange={(e) => setRequestId(e.target.value)}>
              <option value="">不关联</option>
              {options?.requests?.map((r: RequestOption) => <option key={r.id} value={r.id}>{r.order_number}</option>)}
            </select>
          </div>

          <div className="form-group">
            <label className="form-label">订单号 *</label>
            <input className="form-input" value={orderNo} onChange={(e) => setOrderNo(e.target.value)} placeholder="订单号" />
          </div>
          <div className="form-group">
            <label className="form-label">参考号/款号 *</label>
            <input className="form-input" value={referenceNo} onChange={(e) => setReferenceNo(e.target.value)} placeholder="款号" />
          </div>
          <div className="form-group">
            <label className="form-label">验货类型</label>
            <select className="form-input" value={inspectionType} onChange={(e) => setInspectionType(e.target.value)}>
              {options?.inspection_types?.map((t: string) => <option key={t} value={t}>{t}</option>)}
            </select>
          </div>
          <div className="form-group">
            <label className="form-label">验货日期 *</label>
            <input type="date" className="form-input" value={inspectionDate} onChange={(e) => setInspectionDate(e.target.value)} />
          </div>

          <div className="form-group">
            <label className="form-label">供应商</label>
            <select className="form-input" value={supplierId} onChange={(e) => setSupplierId(e.target.value)}>
              <option value="">请选择供应商</option>
              {options?.suppliers?.map((s: Option) => <option key={s.id} value={s.id}>{s.name}</option>)}
            </select>
          </div>
          <div className="form-group">
            <label className="form-label">产品</label>
            <select className="form-input" value={productId} onChange={(e) => setProductId(e.target.value)}>
              <option value="">请选择产品</option>
              {options?.products?.map((p: Option) => <option key={p.id} value={p.id}>{p.name}</option>)}
            </select>
          </div>
        </div>

        <div className="card">
          <div className="section-title">数量统计</div>
          <div className="form-group">
            <label className="form-label">订单数量</label>
            <input type="number" className="form-input" value={orderQty} onChange={(e) => setOrderQty(e.target.value)} placeholder="订单数量" />
          </div>
          <div className="form-group">
            <label className="form-label">出货数量</label>
            <input type="number" className="form-input" value={shipmentQty} onChange={(e) => setShipmentQty(e.target.value)} placeholder="出货数量" />
          </div>
          <div className="form-group">
            <label className="form-label">大缺陷数</label>
            <input type="number" className="form-input" value={majorDefects} onChange={(e) => setMajorDefects(e.target.value)} />
          </div>
          <div className="form-group">
            <label className="form-label">小缺陷数</label>
            <input type="number" className="form-input" value={minorDefects} onChange={(e) => setMinorDefects(e.target.value)} />
          </div>
          <div className="form-group">
            <label className="form-label">不合格数</label>
            <input type="number" className="form-input" value={qtyRejected} onChange={(e) => setQtyRejected(e.target.value)} />
          </div>
        </div>

        <div className="card">
          <div className="section-title">检验结果与备注</div>
          <div className="form-group">
            <label className="form-label">检验结果</label>
            <select className="form-input" value={result} onChange={(e) => setResult(e.target.value)}>
              <option value="">待检验</option>
              <option value="pass">合格</option>
              <option value="fail">不合格</option>
              <option value="conditional">有条件通过</option>
            </select>
          </div>
          <div className="form-group">
            <label className="form-label">备注</label>
            <textarea className="form-input" style={{ minHeight: '80px', resize: 'vertical' }} value={comments} onChange={(e) => setComments(e.target.value)} placeholder="备注信息..." />
          </div>
        </div>
      </div>

      <div className="action-bar">
        <button className="btn btn-primary btn-block" onClick={handleSubmit} disabled={isSaving}>
          {isSaving ? '提交中...' : '提交记录'}
        </button>
      </div>
    </div>
  );
}
