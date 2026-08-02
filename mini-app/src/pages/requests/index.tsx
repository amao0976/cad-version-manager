import React, { useState, useEffect, useCallback } from 'react';
import { View, Text, Input, ScrollView, Button } from '@tarojs/components';
import Taro, { useDidShow, usePullDownRefresh } from '@tarojs/taro';
import { apiService } from '../../services/api';
import { isUserLoggedIn, getStoredUser } from '../../store/auth';
import Card from '../../components/Card';
import StatusBadge from '../../components/StatusBadge';
import Empty from '../../components/Empty';
import styles from './index.module.scss';

const FILTER_TABS = [
  { label: '全部', value: '' },
  { label: '待处理', value: 'pending' },
  { label: '已排期', value: 'scheduled' },
  { label: '已取消', value: 'cancelled' },
];

const STATUS_COLORS: Record<string, { color: string; bg: string }> = {
  pending: { color: '#f59e0b', bg: '#fef3c7' },
  scheduled: { color: '#2563eb', bg: '#dbeafe' },
  cancelled: { color: '#dc2626', bg: '#fee2e2' },
};

function RequestsPage() {
  const [list, setList] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState('');
  const [keyword, setKeyword] = useState('');
  const currentUser = getStoredUser();
  const isSupplier = currentUser?.role === 'supplier';

  const loadData = useCallback(async () => {
    if (!isUserLoggedIn()) {
      Taro.reLaunch({ url: '/pages/login/index' });
      return;
    }
    try {
      setLoading(true);
      const params: Record<string, any> = {};
      if (filter) params.status = filter;
      const res = await apiService.inspectionRequests.list(params);
      setList(res.data || []);
    } catch (err: any) {
      console.error('[Requests] 加载失败:', err);
      Taro.showToast({ title: err?.message || '加载失败', icon: 'none' });
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
          item.order_number?.includes(keyword) ||
          item.style_number?.includes(keyword) ||
          item.supplier?.name?.includes(keyword)
      )
    : list;

  const handleDetail = (id: number) => {
    Taro.navigateTo({ url: `/pages/request-detail/index?id=${id}` });
  };

  const handleCreate = () => {
    Taro.navigateTo({ url: '/pages/create-request/index' });
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
          <Empty text="暂无验货申请" />
        ) : (
          filteredList.map((item) => {
            const sc = STATUS_COLORS[item.status] || {};
            return (
              <Card key={item.id} onClick={() => handleDetail(item.id)}>
                <View className={styles.cardHeader}>
                  <Text className={styles.orderNo}>{item.order_number}</Text>
                  <StatusBadge
                    text={item.status_label || item.status}
                    color={sc.color}
                    bgColor={sc.bg}
                  />
                </View>
                <View className={styles.cardBody}>
                  <Text className={styles.infoItem}>款号: {item.style_number}</Text>
                  <Text className={styles.infoItem}>类型: {item.inspection_type}</Text>
                  {item.supplier && (
                    <Text className={styles.infoItem}>供应商: {item.supplier.name}</Text>
                  )}
                </View>
                <View className={styles.cardFooter}>
                  <Text className={styles.date}>
                    申请日期: {item.requested_date || '未设置'}
                  </Text>
                </View>
              </Card>
            );
          })
        )}
      </ScrollView>
      {isSupplier && (
        <View className={styles.fab} onClick={handleCreate}>
          <Text>+</Text>
        </View>
      )}
    </View>
  );
}

export default RequestsPage;
