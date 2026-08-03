import React, { useState, useEffect } from 'react';
import { View, Text, Button } from '@tarojs/components';
import Taro, { useRouter } from '@tarojs/taro';
import { apiService } from '../../services/api';
import { getStoredUser } from '../../store/auth';
import StatusBadge from '../../components/StatusBadge';
import Empty from '../../components/Empty';
import styles from './index.module.scss';

const RESULT_INFO: Record<string, { color: string; bg: string; label: string }> = {
  pass: { color: '#16a34a', bg: '#dcfce7', label: '合格' },
  fail: { color: '#dc2626', bg: '#fee2e2', label: '不合格' },
  pending: { color: '#f59e0b', bg: '#fef3c7', label: '待检验' },
};

function RecordDetailPage() {
  const router = useRouter();
  const id = Number(router.params.id);
  const [data, setData] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  const loadData = async () => {
    try {
      setLoading(true);
      const res = await apiService.inspectionRecords.get(id);
      setData(res.data);
    } catch (err) {
      console.error('[RecordDetail] 加载失败:', err);
      Taro.showToast({ title: '加载失败', icon: 'none' });
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, [id]);

  const handleJudge = async (result: string) => {
    const labels: Record<string, string> = { pass: '合格', fail: '不合格', pending: '待检验' };
    const res = await Taro.showModal({
      title: '确认判定',
      content: `确定要将此验货记录判定为"${labels[result]}"吗？`,
    });
    if (!res.confirm) return;
    try {
      Taro.showLoading({ title: '处理中...' });
      const user = getStoredUser();
      await apiService.inspectionRecords.update(id, {
        result,
        qc_name: user?.name || '',
      });
      Taro.hideLoading();
      Taro.showToast({ title: '判定成功', icon: 'success' });
      loadData();
    } catch (err: any) {
      Taro.hideLoading();
      Taro.showToast({ title: err.message || '操作失败', icon: 'none' });
    }
  };

  const handleCreateReport = async () => {
    try {
      Taro.showLoading({ title: '创建中...' });
      const res = await apiService.inspectionRecords.createReport(id);
      Taro.hideLoading();
      const reportId = res.data?.id;
      if (reportId) {
        Taro.navigateTo({ url: `/pages/report/index?id=${reportId}` });
      } else {
        Taro.showToast({ title: '创建成功', icon: 'success' });
        loadData();
      }
    } catch (err: any) {
      Taro.hideLoading();
      Taro.showToast({ title: err.message || '创建失败', icon: 'none' });
    }
  };

  const handleViewReport = async () => {
    try {
      const res = await apiService.inspectionRecords.getReport(id);
      const reportId = res.data?.id;
      if (reportId) {
        Taro.navigateTo({ url: `/pages/report/index?id=${reportId}` });
      } else {
        handleCreateReport();
      }
    } catch {
      handleCreateReport();
    }
  };

  if (loading) return <View className={styles.page}><Empty text="加载中..." /></View>;
  if (!data) return <View className={styles.page}><Empty text="未找到验货记录" /></View>;

  const ri = RESULT_INFO[data.result] || {};

  return (
    <View className={styles.page}>
      <View className={styles.section}>
        <View className={styles.sectionTitle}>
          <Text>基本信息</Text>
          <StatusBadge text={ri.label || data.result} color={ri.color} bgColor={ri.bg} />
        </View>
        <View className={styles.infoRow}>
          <Text className={styles.label}>订单号</Text>
          <Text className={styles.value}>{data.order_no}</Text>
        </View>
        <View className={styles.infoRow}>
          <Text className={styles.label}>款号</Text>
          <Text className={styles.value}>{data.reference_no || '-'}</Text>
        </View>
        <View className={styles.infoRow}>
          <Text className={styles.label}>验货类型</Text>
          <Text className={styles.value}>{data.inspection_type}</Text>
        </View>
        <View className={styles.infoRow}>
          <Text className={styles.label}>验货日期</Text>
          <Text className={styles.value}>{data.inspection_date || '-'}</Text>
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
      </View>

      <View className={styles.section}>
        <View className={styles.sectionTitle}><Text>数量统计</Text></View>
        <View className={styles.infoRow}>
          <Text className={styles.label}>订单数量</Text>
          <Text className={styles.value}>{data.order_quantity || '-'}</Text>
        </View>
        <View className={styles.infoRow}>
          <Text className={styles.label}>出货数量</Text>
          <Text className={styles.value}>{data.shipment_quantity || '-'}</Text>
        </View>
        <View className={styles.infoRow}>
          <Text className={styles.label}>主要缺陷</Text>
          <Text className={styles.value}>{data.major_defects ?? '-'}</Text>
        </View>
        <View className={styles.infoRow}>
          <Text className={styles.label}>次要缺陷</Text>
          <Text className={styles.value}>{data.minor_defects ?? '-'}</Text>
        </View>
        <View className={styles.infoRow}>
          <Text className={styles.label}>拒收数量</Text>
          <Text className={styles.value}>{data.qty_rejected ?? '-'}</Text>
        </View>
        {data.qc_name && (
          <View className={styles.infoRow}>
            <Text className={styles.label}>QC检验员</Text>
            <Text className={styles.value}>{data.qc_name}</Text>
          </View>
        )}
      </View>

      <View className={styles.section}>
        <View className={styles.sectionTitle}><Text>验货结果判定</Text></View>
        <View className={styles.resultSection}>
          <Text className={`${styles.resultText} ${
            data.result === 'pass' ? styles.resultPass :
            data.result === 'fail' ? styles.resultFail : styles.resultPending
          }`}>
            {ri.label || '待检验'}
          </Text>
          <View className={styles.judgeBtns}>
            <Button
              className={`${styles.judgeBtn} ${styles.judgePass}`}
              onClick={() => handleJudge('pass')}
            >
              判定合格
            </Button>
            <Button
              className={`${styles.judgeBtn} ${styles.judgeFail}`}
              onClick={() => handleJudge('fail')}
            >
              判定不合格
            </Button>
          </View>
          {data.result !== 'pending' && (
            <Button
              className={`${styles.judgeBtn} ${styles.judgeReset}`}
              style={{ marginTop: '16rpx' }}
              onClick={() => handleJudge('pending')}
            >
              重置为待检验
            </Button>
          )}
        </View>
      </View>

      {data.comments && (
        <View className={styles.section}>
          <View className={styles.sectionTitle}><Text>备注</Text></View>
          <Text style={{ fontSize: '28rpx', color: '#4e5969', lineHeight: '1.6' }}>{data.comments}</Text>
        </View>
      )}

      <View className={styles.actionBar}>
        <Button className={styles.reportBtn} onClick={data.has_report ? handleViewReport : handleCreateReport}>
          {data.has_report ? '📄 查看验货报告' : '📄 创建验货报告（可选）'}
        </Button>
      </View>
    </View>
  );
}

export default RecordDetailPage;
