import React, { useState, useEffect, useRef } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { apiService } from '../services/api';

const CATEGORIES = [
  { key: 'product_overview', label: '产品外观', icon: '👁️' },
  { key: 'label_hangtag', label: '标签吊牌', icon: '🏷️' },
  { key: 'rfid', label: 'RFID', icon: '📡' },
  { key: 'defect_detail', label: '缺陷细节', icon: '⚠️' },
];

interface ImageItem {
  id: number;
  url: string;
}

export default function ReportScreen() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [report, setReport] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [activeCategory, setActiveCategory] = useState('product_overview');
  const [images, setImages] = useState<Record<string, ImageItem[]>>({});
  const [isUploading, setIsUploading] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  const [error, setError] = useState('');
  const [showSourceChoice, setShowSourceChoice] = useState(false);

  const cameraInputRef = useRef<HTMLInputElement>(null);
  const galleryInputRef = useRef<HTMLInputElement>(null);

  const loadReport = async () => {
    try {
      setIsLoading(true);
      const response = await apiService.inspectionReports.get(Number(id));
      const data = response.data.data;
      if (data) {
        setReport(data);
        setImages(data.images || {});
      }
    } catch (err: any) {
      setError(err.response?.data?.error || '加载报告失败');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => { loadReport(); }, [id]);

  const handlePickSource = () => {
    setShowSourceChoice(true);
  };

  const handleFileSelect = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = e.target.files;
    if (!files || files.length === 0) return;
    setShowSourceChoice(false);

    for (let i = 0; i < files.length; i++) {
      await uploadFile(files[i]);
    }
    e.target.value = '';
  };

  const uploadFile = async (file: File) => {
    if (!report) return;
    setIsUploading(true);
    setError('');
    try {
      const formData = new FormData();
      formData.append('category', activeCategory);
      formData.append('image', file);
      const response = await apiService.inspectionReports.uploadImage(report.id, formData);
      const newImages = response.data.data?.images;
      if (newImages) setImages(newImages);
    } catch (err: any) {
      const errData = err.response?.data;
      setError(errData?.error || errData?.message || '图片上传失败');
    } finally {
      setIsUploading(false);
    }
  };

  const handleRemoveImage = async (imageId: number) => {
    if (!report) return;
    try {
      const response = await apiService.inspectionReports.removeImage(report.id, imageId);
      const newImages = response.data.data?.images;
      if (newImages) setImages(newImages);
    } catch (err: any) {
      setError(err.response?.data?.error || '删除失败');
    }
  };

  const handleComplete = async () => {
    setError('');
    try {
      setIsSaving(true);
      await apiService.inspectionReports.complete(report.id);
      alert('报告已完成');
      navigate(-1);
    } catch (err: any) {
      setError(err.response?.data?.error || '操作失败');
    } finally {
      setIsSaving(false);
    }
  };

  if (isLoading) return <div className="loading-container"><div className="loading-spinner" /></div>;
  if (!report) return (
    <div>
      <div style={{ padding: '12px' }}><button className="btn btn-secondary" onClick={() => navigate(-1)}>← 返回</button></div>
      <div className="empty-state"><div className="empty-state-text">未找到报告，请先在验货记录中创建报告</div></div>
    </div>
  );

  const currentImages = images[activeCategory] || [];

  return (
    <div>
      <div style={{ padding: '12px', display: 'flex', gap: '8px' }}>
        <button className="btn btn-secondary" onClick={() => navigate(-1)}>← 返回</button>
        <h2 style={{ flex: 1, fontSize: '18px', fontWeight: 600 }}>验货报告</h2>
        <span className="badge badge-pending">{report.status_label}</span>
      </div>

      {error && <div style={{ margin: '0 12px 12px', background: '#fee2e2', color: '#dc2626', padding: '10px', borderRadius: '8px', fontSize: '14px' }}>{error}</div>}

      <div style={{ padding: '12px' }}>
        <div className="card">
          <div className="section-title">基本信息</div>
          {report.inspection_record && (
            <>
              <div className="info-row"><span className="info-label">订单号:</span><span className="info-value">{report.inspection_record.order_no}</span></div>
              <div className="info-row"><span className="info-label">款号:</span><span className="info-value">{report.inspection_record.reference_no || 'N/A'}</span></div>
            </>
          )}
        </div>

        <div className="card">
          <div className="section-title">产品细节照片</div>
          <div className="category-tabs">
            {CATEGORIES.map(c => (
              <button
                key={c.key}
                className={`category-tab ${activeCategory === c.key ? 'active' : ''}`}
                onClick={() => setActiveCategory(c.key)}
              >
                {c.icon} {c.label} ({(images[c.key] || []).length})
              </button>
            ))}
          </div>

          <div style={{ marginTop: '12px' }}>
            {/* 上传按钮 */}
            <div
              className="image-upload"
              onClick={handlePickSource}
              style={{ cursor: 'pointer', border: '2px dashed #d1d5db', borderRadius: '8px', padding: '20px', textAlign: 'center' }}
            >
              <div style={{ fontSize: '36px' }}>📷</div>
              <div style={{ color: '#6b7280', fontSize: '14px', marginTop: '4px' }}>
                点击上传 {CATEGORIES.find(c => c.key === activeCategory)?.label} 照片
              </div>
              <div style={{ color: '#9ca3af', fontSize: '12px', marginTop: '2px' }}>可选择相册照片或当场拍照</div>
            </div>

            {/* 隐藏的文件输入 - 拍照 */}
            <input
              ref={cameraInputRef}
              type="file"
              accept="image/*"
              capture="environment"
              style={{ display: 'none' }}
              onChange={handleFileSelect}
            />
            {/* 隐藏的文件输入 - 相册（支持多选） */}
            <input
              ref={galleryInputRef}
              type="file"
              accept="image/*"
              multiple
              style={{ display: 'none' }}
              onChange={handleFileSelect}
            />

            {/* 上传中提示 */}
            {isUploading && (
              <div style={{ textAlign: 'center', padding: '12px', color: '#3b82f6', fontSize: '14px' }}>
                上传中...
              </div>
            )}

            {/* 图片预览网格 */}
            {currentImages.length > 0 && (
              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '8px', marginTop: '12px' }}>
                {currentImages.map((img, idx) => (
                  <div key={img.id || idx} style={{ position: 'relative', paddingTop: '100%', overflow: 'hidden', borderRadius: '8px', background: '#f3f4f6' }}>
                    <img
                      src={img.url}
                      alt={`${activeCategory}-${idx}`}
                      style={{ position: 'absolute', top: 0, left: 0, width: '100%', height: '100%', objectFit: 'cover' }}
                      onClick={() => window.open(img.url, '_blank')}
                    />
                    <button
                      onClick={(e) => { e.stopPropagation(); handleRemoveImage(img.id); }}
                      style={{
                        position: 'absolute', top: '4px', right: '4px',
                        background: 'rgba(239,68,68,0.9)', color: 'white',
                        border: 'none', borderRadius: '50%', width: '24px', height: '24px',
                        fontSize: '14px', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center'
                      }}
                    >✕</button>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>

      <div className="action-bar">
        <button className="btn btn-success btn-block" onClick={handleComplete} disabled={isSaving || isUploading}>
          {isSaving ? '提交中...' : '完成报告'}
        </button>
      </div>

      {/* 选择来源弹窗 */}
      {showSourceChoice && (
        <div
          style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.5)', display: 'flex', alignItems: 'flex-end', zIndex: 1000 }}
          onClick={() => setShowSourceChoice(false)}
        >
          <div
            style={{ background: 'white', width: '100%', borderRadius: '16px 16px 0 0', padding: '16px' }}
            onClick={(e) => e.stopPropagation()}
          >
            <div style={{ textAlign: 'center', fontSize: '16px', fontWeight: 600, marginBottom: '16px' }}>
              选择图片来源
            </div>
            <button
              className="btn btn-primary btn-block"
              style={{ marginBottom: '8px' }}
              onClick={() => { setShowSourceChoice(false); cameraInputRef.current?.click(); }}
            >
              📷 当场拍照
            </button>
            <button
              className="btn btn-secondary btn-block"
              style={{ marginBottom: '8px' }}
              onClick={() => { setShowSourceChoice(false); galleryInputRef.current?.click(); }}
            >
              🖼️ 从相册选择（可多选）
            </button>
            <button className="btn btn-block" onClick={() => setShowSourceChoice(false)}>取消</button>
          </div>
        </div>
      )}
    </div>
  );
}
