import React, { useState, useEffect } from 'react';
import { View, Text, Button } from '@tarojs/components';
import Taro, { useRouter } from '@tarojs/taro';
import { apiService } from '../../services/api';
import { getStoredUser } from '../../store/auth';
import StatusBadge from '../../components/StatusBadge';
import Empty from '../../components/Empty';
import styles from './index.module.scss';

const STATUS_COLORS: Record<string, { color: string; bg: string }> = {
  pending: { color: '#f59e0b', bg: '#fef3c7' },
  scheduled: { color: '#2563eb', bg: '#dbeafe' },
  cancelled: { color: '#dc2626', bg: '#fee2e2' },
};

function RequestDetailPage() {
  const router = useRouter();
  const id = Number(router.params.id);
  const [data, setData] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const currentUser = getStoredUser();
  const isQC = currentUser?.role === 'qc' || currentUser?.role === 'admin';

  const loadData = async () => {
    try {
      setLoading(true);
      const res = await apiService.inspectionRequests.get(id);
      setData(res.data);
    } catch (err) {
      console.error('[RequestDetail] 加载失败:', err);
      Taro.showToast({ title: '加载失败', icon: 'none' });
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, [id]);

  const handleSchedule = async () => {
    const res = await Taro.showModal({ title: '确认排期', content: '确定要确认排期吗？确认后将进入验货记录创建流程。' });
    if (!res.confirm) return;
    try {
      Taro.showLoading({ title: '处理中...' });
      const response = await apiService.inspectionRequests.schedule(id);
      Taro.hideLoading();
      Taro.showToast({ title: '排期成功', icon: 'success' });
      // 排期成功后跳转到创建验货记录
      const redirect = response.data?.redirect;
      const requestId = response.data?.id || id;
      setTimeout(() => {
        Taro.redirectTo({
          url: `/pages/create-record/index?request_id=${requestId}`,
        });
      }, 500);
    } catch (err: any) {
      Taro.hideLoading();
      Taro.showToast({ title: err.message || '操作失败', icon: 'none' });
    }
  };

  const handleCancel = async () => {
    const res = await Taro.showModal({ title: '取消申请', content: '确定要取消此验货申请吗？', confirmColor: '#dc2626' });
    if (!res.confirm) return;
    try {
      Taro.showLoading({ title: '处理中...' });
      await apiService.inspectionRequests.cancel(id);
      Taro.hideLoading();
      Taro.showToast({ title: '已取消', icon: 'success' });
      loadData();
    } catch (err: any) {
      Taro.hideLoading();
      Taro.showToast({ title: err.message || '操作失败', icon: 'none' });
    }
  };

  const handleCreateRecord = () => {
    Taro.navigateTo({ url: `/pages/create-record/index?request_id=${id}` });
  };

  if (loading) return <View className={styles.page}><Empty text="加载中..." /></View>;
  if (!data) return <View className={styles.page}><Empty text="未找到验货申请" /></View>;

  const sc = STATUS_COLORS[data.status] || {};

  return (
    <View className={styles.page}>
      <View className={styles.section}>
        <View className={styles.sectionTitle}>
          <Text>基本信息</Text>
          <StatusBadge text={data.status_label || data.status} color={sc.color} bgColor={sc.bg} />
        </View>
        <View className={styles.infoRow}>
          <Text className={styles.label}>订单号</Text>
          <Text className={styles.value}>{data.order_number}</Text>
        </View>
        <View className={styles.infoRow}>
          <Text className={styles.label}>款号</Text>
          <Text className={styles.value}>{data.style_number}</Text>
        </View>
        <View className={styles.infoRow}>
          <Text className={styles.label}>验货类型</Text>
          <Text className={styles.value}>{data.inspection_type}</Text>
        </View>
        <View className={styles.infoRow}>
          <Text className={styles.label}>申请日期</Text>
          <Text className={styles.value}>{data.requested_date || '未设置'}</Text>
        </View>
        {data.supplier && (
          <View className={styles.infoRow}>
            <Text className={styles.label}>供应商</Text>
            <Text className={styles.value}>{data.supplier.name}</Text>
          </View>
        )}
        {data.product && (
          <View className={styles.infoRow}>
            <Text className={styles.label}>产品</Text>
            <Text className={styles.value}>{data.product.name}</Text>
          </View>
        )}
        {data.remarks && (
          <View className={styles.infoRow}>
            <Text className={styles.label}>备注</Text>
            <Text className={styles.value}>{data.remarks}</Text>
          </View>
        )}
      </View>

      {data.items && data.items.length > 0 && (
        <View className={styles.section}>
          <View className={styles.sectionTitle}>
            <Text>明细项 ({data.items.length})</Text>
          </View>
          {data.items.map((item: any, idx: number) => (
            <View key={item.id || idx} className={styles.itemRow}>
              <Text className={styles.itemOrder}>订单: {item.order_number} | 款号: {item.style_number}</Text>
              <Text className={styles.itemInfo}>
                数量: {item.quantity} | 检验水平: {item.inspection_level} | AQL: {item.aql_level}
              </Text>
              {item.sample_size && (
                <Text className={styles.itemInfo}>
                  抽样数: {item.sample_size} | 接受: {item.accept_number} | 拒收: {item.reject_number}
                </Text>
              )}
            </View>
          ))}
        </View>
      )}

      <View className={styles.actionBar}>
        {isQC && data.status === 'pending' && data.can_schedule && (
          <Button className={`${styles.btn} ${styles.btnWarning}`} onClick={handleSchedule}>
            QC确认排期
          </Button>
        )}
        {data.status === 'pending' && data.can_cancel && (
          <Button className={`${styles.btn} ${styles.btnOutline}`} onClick={handleCancel}>
            取消申请
          </Button>
        )}
        {isQC && data.status === 'scheduled' && (
          <Button className={`${styles.btn} ${styles.btnPrimary}`} onClick={handleCreateRecord}>
            创建验货记录
          </Button>
        )}
      </View>
    </View>
  );
}

export default RequestDetailPage;
