import React, { useState, useEffect, useCallback, useRef } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { apiService } from '../services/api';

const CATEGORIES = [
  { key: 'appearance', label: '外观', icon: '👁️' },
  { key: 'function', label: '功能', icon: '⚙️' },
  { key: 'packaging', label: '包装', icon: '📦' },
  { key: 'raw_material', label: '原材料', icon: '🧪' },
  { key: 'accessory', label: '配件', icon: '🔧' },
];

export default function ReportScreen() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [report, setReport] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [activeCategory, setActiveCategory] = useState('appearance');
  const [images, setImages] = useState<Record<string, string[]>>({});
  const [notes, setNotes] = useState<Record<string, string>>({});
  const [isSaving, setIsSaving] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);
  const pendingFile = useRef<{ category: string; file: File } | null>(null);

  const loadReport = useCallback(async () => {
    try {
      setIsLoading(true);
      const response = await apiService.inspectionRecords.getReport(Number(id));
      const data = response.data.data || response.data;
      setReport(data);
      if (data?.images) setImages(data.images);
      if (data?.notes) setNotes(data.notes);
    } catch (error) {
      console.error('加载报告失败:', error);
    } finally {
      setIsLoading(false);
    }
  }, [id]);

  useEffect(() => { loadReport(); }, [loadReport]);

  const handleFileSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    pendingFile.current = { category: activeCategory, file };
    e.target.value = '';
    uploadCurrentFile();
  };

  const uploadCurrentFile = async () => {
    if (!pendingFile.current) return;
    const { category, file } = pendingFile.current;
    try {
      const formData = new FormData();
      formData.append('inspection_report[category]', category);
      formData.append('inspection_report[image]', file);
      const response = await apiService.inspectionReports.uploadImage(report.id, formData);
      const newImages = { ...images };
      if (!newImages[category]) newImages[category] = [];
      newImages[category] = [...newImages[category], response.data.image_url];
      setImages(newImages);
      pendingFile.current = null;
    } catch (error) {
      console.error('上传失败:', error);
      alert('上传图片失败');
      pendingFile.current = null;
    }
  };

  const handleSave = async () => {
    try {
      setIsSaving(true);
      await apiService.inspectionReports.complete(report.id);
      alert('报告已保存');
    } catch (error: any) {
      alert(error.response?.data?.error || '保存失败');
    } finally {
      setIsSaving(false);
    }
  };

  const handleSaveDraft = async () => {
    try {
      setIsSaving(true);
      await apiService.inspectionReports.reopen(report.id);
      alert('草稿已保存');
    } catch (error: any) {
      alert(error.response?.data?.error || '保存失败');
    } finally {
      setIsSaving(false);
    }
  };

  if (isLoading) return <div className="loading-container"><div className="loading-spinner" /></div>;
  if (!report) return <div className="empty-state"><div className="empty-state-text">未找到报告</div></div>;

  return (
    <div>
      <div style={{ padding: '12px', display: 'flex', gap: '8px' }}>
        <button className="btn btn-secondary" onClick={() => navigate(-1)}>← 返回</button>
      </div>

      <div style={{ padding: '12px' }}>
        <div className="card">
          <div className="card-header">
            <span className="card-title">验货报告</span>
            <span className="badge badge-pending">{report.status_label}</span>
          </div>
          <div className="info-row"><span className="info-label">订单号:</span><span className="info-value">{report.order_no}</span></div>
          <div className="info-row"><span className="info-label">款号:</span><span className="info-value">{report.style_number || 'N/A'}</span></div>
        </div>

        <div className="card">
          <div className="section-title">分类检验</div>
          <div className="category-tabs">
            {CATEGORIES.map(c => (
              <button
                key={c.key}
                className={`category-tab ${activeCategory === c.key ? 'active' : ''}`}
                onClick={() => setActiveCategory(c.key)}
              >
                {c.icon} {c.label}
              </button>
            ))}
          </div>

          <div style={{ marginTop: '12px' }}>
            <div 
              className="image-upload" 
              onClick={() => fileInputRef.current?.click()}
            >
              <div className="empty-state-icon" style={{ fontSize: '36px' }}>📷</div>
              <div className="image-upload-text">点击上传 {CATEGORIES.find(c => c.key === activeCategory)?.label} 相关图片</div>
              <input
                ref={fileInputRef}
                type="file"
                accept="image/*"
                capture="environment"
                style={{ display: 'none' }}
                onChange={handleFileSelect}
              />
            </div>

            {images[activeCategory] && images[activeCategory].length > 0 && (
              <div className="image-preview">
                {images[activeCategory].map((url, idx) => (
                  <img key={idx} src={url} alt={`${activeCategory}-${idx}`} className="preview-image" />
                ))}
              </div>
            )}

            <div style={{ marginTop: '16px' }}>
              <label className="form-label">检验备注</label>
              <textarea
                className="form-input"
                style={{ minHeight: '80px', resize: 'vertical' }}
                placeholder={`记录${CATEGORIES.find(c => c.key === activeCategory)?.label}检验情况...`}
                value={notes[activeCategory] || ''}
                onChange={(e) => setNotes({ ...notes, [activeCategory]: e.target.value })}
              />
            </div>
          </div>
        </div>

        <div className="card">
          <div className="section-title">整体备注</div>
          <textarea
            className="form-input"
            style={{ minHeight: '100px', resize: 'vertical' }}
            placeholder="记录整体检验情况、问题描述等..."
            value={notes['overall'] || ''}
            onChange={(e) => setNotes({ ...notes, overall: e.target.value })}
          />
        </div>
      </div>

      <div className="action-bar">
        <button className="btn btn-secondary" onClick={handleSaveDraft} disabled={isSaving}>保存草稿</button>
        <button className="btn btn-success" onClick={handleSave} disabled={isSaving}>提交报告</button>
      </div>
    </div>
  );
}
