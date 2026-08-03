import React, { useState, useEffect, useCallback } from 'react';
import { View, Text, Input, ScrollView } from '@tarojs/components';
import Taro, { useDidShow, usePullDownRefresh } from '@tarojs/taro';
import { apiService } from '../../services/api';
import { isUserLoggedIn } from '../../store/auth';
import Card from '../../components/Card';
import StatusBadge from '../../components/StatusBadge';
import Empty from '../../components/Empty';
import styles from './index.module.scss';

const FILTER_TABS = [
  { label: '全部', value: '' },
  { label: '合格', value: 'pass' },
  { label: '不合格', value: 'fail' },
  { label: '待检验', value: 'pending' },
];

const RESULT_COLORS: Record<string, { color: string; bg: string; label: string }> = {
  pass: { color: '#16a34a', bg: '#dcfce7', label: '合格' },
  fail: { color: '#dc2626', bg: '#fee2e2', label: '不合格' },
  pending: { color: '#f59e0b', bg: '#fef3c7', label: '待检验' },
};

function RecordsPage() {
  const [list, setList] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState('');
  const [keyword, setKeyword] = useState('');

  const loadData = useCallback(async () => {
    if (!isUserLoggedIn()) {
      Taro.reLaunch({ url: '/pages/login/index' });
      return;
    }
    try {
      setLoading(true);
      const params: Record<string, any> = {};
      if (filter) params.result = filter;
      const res = await apiService.inspectionRecords.list(params);
      setList(res.data || []);
    } catch (err) {
      console.error('[Records] 加载失败:', err);
      Taro.showToast({ title: '加载失败', icon: 'none' });
    } finally {
      setLoading(false);
    }
  }, [filter]);

  useEffect(() => {
    loadData();
  }, [loadData]);

  useDidShow(() => {
    loadData();
  });

  usePullDownRefresh(() => {
    loadData().then(() => Taro.stopPullDownRefresh());
  });

  const filteredList = keyword
    ? list.filter(
        (item) =>
          item.order_no?.includes(keyword) ||
          item.reference_no?.includes(keyword) ||
          item.supplier?.name?.includes(keyword)
      )
    : list;

  const handleDetail = (id: number) => {
    Taro.navigateTo({ url: `/pages/record-detail/index?id=${id}` });
  };

  const handleCreate = () => {
    Taro.navigateTo({ url: '/pages/create-record/index' });
  };

  return (
    <View className={styles.page}>
      <View className={styles.searchBar}>
        <Input
          className={styles.searchInput}
          placeholder="搜索订单号/款号/供应商"
          value={keyword}
          onInput={(e) => setKeyword(e.detail.value)}
        />
      </View>
      <ScrollView scrollX className={styles.filterTabs}>
        {FILTER_TABS.map((tab) => (
          <View
            key={tab.value}
            className={`${styles.filterTab} ${filter === tab.value ? styles.filterTabActive : ''}`}
            onClick={() => setFilter(tab.value)}
          >
            <Text>{tab.label}</Text>
          </View>
        ))}
      </ScrollView>
      <ScrollView scrollY className={styles.list} style={{ height: 'calc(100vh - 200rpx)' }}>
        {loading && list.length === 0 ? (
          <Empty text="加载中..." />
        ) : filteredList.length === 0 ? (
          <Empty text="暂无验货记录" />
        ) : (
          filteredList.map((item) => {
            const rc = RESULT_COLORS[item.result] || {};
            return (
              <Card key={item.id} onClick={() => handleDetail(item.id)}>
                <View className={styles.cardHeader}>
                  <Text className={styles.orderNo}>{item.order_no}</Text>
                  <StatusBadge
                    text={rc.label || item.result}
                    color={rc.color}
                    bgColor={rc.bg}
                  />
                </View>
                <View className={styles.cardBody}>
                  <Text className={styles.infoItem}>款号: {item.reference_no || '-'}</Text>
                  <Text className={styles.infoItem}>类型: {item.inspection_type}</Text>
                  {item.supplier && (
                    <Text className={styles.infoItem}>供应商: {item.supplier.name}</Text>
                  )}
                </View>
                <View className={styles.cardFooter}>
                  <Text className={styles.date}>
                    验货日期: {item.inspection_date || '未设置'}
                  </Text>
                  {item.has_report && (
                    <Text className={styles.reportTag}>📄 有报告</Text>
                  )}
                </View>
              </Card>
            );
          })
        )}
      </ScrollView>
      <View className={styles.fab} onClick={handleCreate}>
        <Text>+</Text>
      </View>
    </View>
  );
}

export default RecordsPage;
