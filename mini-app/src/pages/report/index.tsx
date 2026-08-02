import React, { useState, useEffect } from 'react';
import { View, Text, Image, Button } from '@tarojs/components';
import Taro, { useRouter } from '@tarojs/taro';
import { apiService } from '../../services/api';
import Empty from '../../components/Empty';
import styles from './index.module.scss';

const IMAGE_CATEGORIES = [
  { key: 'product_overview', label: '产品外观' },
  { key: 'defect_detail', label: '缺陷细节' },
  { key: 'label_hangtag', label: '标签吊牌' },
  { key: 'rfid', label: 'RFID' },
];

function ReportPage() {
  const router = useRouter();
  const id = Number(router.params.id);
  const [report, setReport] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [activeCategory, setActiveCategory] = useState('product_overview');
  const [error, setError] = useState('');
  const [uploading, setUploading] = useState(false);

  const loadData = async () => {
    try {
      setLoading(true);
      const res = await apiService.inspectionReports.get(id);
      setReport(res.data);
    } catch (err) {
      console.error('[Report] 加载失败:', err);
      Taro.showToast({ title: '加载失败', icon: 'none' });
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, [id]);

  const handleChooseImage = () => {
    Taro.chooseImage({
      count: 9,
      sourceType: ['album', 'camera'],
      success: async (res) => {
        setUploading(true);
        setError('');
        for (const filePath of res.tempFilePaths) {
          try {
            const uploadRes = await apiService.inspectionReports.uploadImage(
              id,
              filePath,
              activeCategory
            );
            setReport(uploadRes.data || report);
          } catch (err: any) {
            setError(err.message || '图片上传失败');
          }
        }
        setUploading(false);
        loadData();
      },
    });
  };

  const handleRemoveImage = (attachmentId: number) => {
    Taro.showModal({
      title: '删除图片',
      content: '确定要删除这张图片吗？',
      confirmColor: '#dc2626',
      success: async (res) => {
        if (res.confirm) {
          try {
            await apiService.inspectionReports.removeImage(id, attachmentId);
            Taro.showToast({ title: '已删除', icon: 'success' });
            loadData();
          } catch (err: any) {
            Taro.showToast({ title: err.message || '删除失败', icon: 'none' });
          }
        }
      },
    });
  };

  const handleComplete = async () => {
    try {
      Taro.showLoading({ title: '处理中...' });
      await apiService.inspectionReports.complete(id);
      Taro.hideLoading();
      Taro.showToast({ title: '报告已完成', icon: 'success' });
      loadData();
    } catch (err: any) {
      Taro.hideLoading();
      Taro.showToast({ title: err.message || '操作失败', icon: 'none' });
    }
  };

  const handlePreviewImage = (url: string, urls: string[]) => {
    Taro.previewImage({ current: url, urls });
  };

  if (loading) return <View className={styles.page}><Empty text="加载中..." /></View>;
  if (!report) return <View className={styles.page}><Empty text="未找到验货报告" /></View>;

  const images = (report.images && report.images[activeCategory]) || [];
  const allImageUrls = IMAGE_CATEGORIES.flatMap((c) => report.images?.[c.key] || []).map((img: any) => img.url);

  return (
    <View className={styles.page}>
      <View className={styles.section}>
        <View className={styles.sectionTitle}><Text>报告信息</Text></View>
        <View className={styles.infoRow}>
          <Text className={styles.label}>报告ID</Text>
          <Text className={styles.value}>#{report.id}</Text>
        </View>
        <View className={styles.infoRow}>
          <Text className={styles.label}>状态</Text>
          <Text className={styles.value}>
            {report.status === 'completed' ? '已完成' : '草稿'}
          </Text>
        </View>
        {report.created_at && (
          <View className={styles.infoRow}>
            <Text className={styles.label}>创建时间</Text>
            <Text className={styles.value}>{report.created_at}</Text>
          </View>
        )}
        {report.summary && (
          <View style={{ marginTop: '16rpx' }}>
            <Text className={styles.summary}>{report.summary}</Text>
          </View>
        )}
      </View>

      <View className={styles.section}>
        <View className={styles.sectionTitle}><Text>产品图片</Text></View>
        <View className={styles.categoryTabs}>
          {IMAGE_CATEGORIES.map((cat) => (
            <View
              key={cat.key}
              className={`${styles.categoryTab} ${activeCategory === cat.key ? styles.categoryTabActive : ''}`}
              onClick={() => setActiveCategory(cat.key)}
            >
              <Text>{cat.label}</Text>
            </View>
          ))}
        </View>
        <View className={styles.imageGrid}>
          {images.map((img: any, idx: number) => (
            <View key={idx} className={styles.imageItem}>
              <Image
                src={img.url}
                className={styles.image}
                mode="aspectFill"
                onClick={() => handlePreviewImage(img.url, allImageUrls)}
              />
              <View
                className={styles.removeBtn}
                onClick={() => handleRemoveImage(img.id)}
              >
                <Text>×</Text>
              </View>
            </View>
          ))}
          <View className={styles.uploadBtn} onClick={handleChooseImage}>
            <Text>{uploading ? '...' : '+'}</Text>
          </View>
        </View>
        {images.length === 0 && !uploading && (
          <Text className={styles.emptyImages}>暂无图片，点击 + 上传</Text>
        )}
      </View>

      {error && <Text className={styles.errorText}>{error}</Text>}

      {report.status !== 'completed' && (
        <View className={styles.actionBar}>
          <Button className={styles.completeBtn} onClick={handleComplete}>
            完成报告
          </Button>
        </View>
      )}
    </View>
  );
}

export default ReportPage;
