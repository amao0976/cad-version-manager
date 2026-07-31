import React, { useState, useEffect, useCallback } from 'react';
import { View, FlatList, StyleSheet, TouchableOpacity, RefreshControl } from 'react-native';
import { Card, Text, Button, TextInput, ActivityIndicator } from 'react-native-paper';
import { useNavigation } from '@react-navigation/native';
import api from '../../services/api';

interface InspectionRequest {
  id: number;
  order_number: string;
  style_number: string;
  quantity: number;
  status: string;
  status_label: string;
  inspection_type: string;
  requested_date: string;
  result: string | null;
  supplier: { id: number; name: string } | null;
  product: { id: number; name: string; product_code: string } | null;
  can_schedule: boolean;
  can_complete: boolean;
  can_cancel: boolean;
}

export default function RequestListScreen() {
  const navigation = useNavigation<any>();
  const [requests, setRequests] = useState<InspectionRequest[]>([]);
  const [filteredRequests, setFilteredRequests] = useState<InspectionRequest[]>([]);
  const [keyword, setKeyword] = useState('');
  const [selectedStatus, setSelectedStatus] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isRefreshing, setIsRefreshing] = useState(false);

  const loadRequests = useCallback(async () => {
    try {
      setIsLoading(true);
      const response = await api.get('/inspection/requests');
      setRequests(response.data.data || response.data);
    } catch (error) {
      console.error('加载验货申请失败:', error);
    } finally {
      setIsLoading(false);
    }
  }, []);

  const handleRefresh = async () => {
    setIsRefreshing(true);
    await loadRequests();
    setIsRefreshing(false);
  };

  useEffect(() => {
    loadRequests();
  }, [loadRequests]);

  useEffect(() => {
    let filtered = requests;
    
    if (keyword) {
      filtered = filtered.filter(
        r => 
          r.order_number.toLowerCase().includes(keyword.toLowerCase()) ||
          r.style_number?.toLowerCase().includes(keyword.toLowerCase())
      );
    }
    
    if (selectedStatus) {
      filtered = filtered.filter(r => r.status === selectedStatus);
    }
    
    setFilteredRequests(filtered);
  }, [requests, keyword, selectedStatus]);

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'pending': return '#f59e0b';
      case 'scheduled': return '#2563eb';
      case 'completed': return '#16a34a';
      case 'cancelled': return '#dc2626';
      default: return '#6b7280';
    }
  };

  const getResultColor = (result: string | null) => {
    if (!result) return '#6b7280';
    return result === 'PASS' ? '#16a34a' : '#dc2626';
  };

  const renderItem = ({ item }: { item: InspectionRequest }) => (
    <Card style={styles.card} onPress={() => navigation.navigate('RequestDetail', { id: item.id })}>
      <Card.Content>
        <View style={styles.cardHeader}>
          <Text style={styles.orderNumber}>{item.order_number}</Text>
          <View style={[styles.statusBadge, { backgroundColor: getStatusColor(item.status) }]}>
            <Text style={styles.statusText}>{item.status_label}</Text>
          </View>
        </View>
        
        <View style={styles.cardBody}>
          <View style={styles.infoRow}>
            <Text style={styles.label}>款号:</Text>
            <Text style={styles.value}>{item.style_number}</Text>
          </View>
          <View style={styles.infoRow}>
            <Text style={styles.label}>数量:</Text>
            <Text style={styles.value}>{item.quantity}</Text>
          </View>
          <View style={styles.infoRow}>
            <Text style={styles.label}>类型:</Text>
            <Text style={styles.value}>{item.inspection_type}</Text>
          </View>
          <View style={styles.infoRow}>
            <Text style={styles.label}>供应商:</Text>
            <Text style={styles.value}>{item.supplier?.name || 'N/A'}</Text>
          </View>
          <View style={styles.infoRow}>
            <Text style={styles.label}>日期:</Text>
            <Text style={styles.value}>{new Date(item.requested_date).toLocaleDateString()}</Text>
          </View>
          {item.result && (
            <View style={styles.infoRow}>
              <Text style={styles.label}>结果:</Text>
              <Text style={[styles.resultText, { color: getResultColor(item.result) }]}>
                {item.result === 'PASS' ? '合格' : '不合格'}
              </Text>
            </View>
          )}
        </View>
      </Card.Content>
    </Card>
  );

  const renderStatusFilter = () => {
    const statuses = [
      { key: null, label: '全部' },
      { key: 'pending', label: '待处理' },
      { key: 'scheduled', label: '已排期' },
      { key: 'completed', label: '已完成' },
      { key: 'cancelled', label: '已取消' },
    ];

    return (
      <View style={styles.filterContainer}>
        <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.statusFilter}>
          {statuses.map(status => (
            <TouchableOpacity
              key={status.key || 'all'}
              style={[
                styles.statusChip,
                selectedStatus === status.key && styles.statusChipSelected
              ]}
              onPress={() => setSelectedStatus(status.key)}
            >
              <Text style={[
                styles.statusChipText,
                selectedStatus === status.key && styles.statusChipTextSelected
              ]}>
                {status.label}
              </Text>
            </TouchableOpacity>
          ))}
        </ScrollView>
      </View>
    );
  };

  if (isLoading) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color="#2563EB" />
        <Text style={styles.loadingText}>加载中...</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <View style={styles.searchContainer}>
        <TextInput
          placeholder="搜索订单号或款号"
          value={keyword}
          onChangeText={setKeyword}
          style={styles.searchInput}
          mode="outlined"
          left={<TextInput.Icon icon="magnify" />}
        />
      </View>
      
      {renderStatusFilter()}
      
      <FlatList
        data={filteredRequests}
        renderItem={renderItem}
        keyExtractor={(item) => item.id.toString()}
        contentContainerStyle={styles.listContent}
        refreshControl={
          <RefreshControl refreshing={isRefreshing} onRefresh={handleRefresh} />
        }
        ListEmptyComponent={
          <View style={styles.emptyContainer}>
            <Text style={styles.emptyText}>暂无验货申请</Text>
          </View>
        }
      />
    </View>
  );
}

import { ScrollView } from 'react-native';

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  searchContainer: {
    padding: 10,
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  searchInput: {
    backgroundColor: '#fff',
  },
  filterContainer: {
    padding: 10,
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  statusFilter: {
    flexGrow: 0,
  },
  statusChip: {
    paddingHorizontal: 16,
    paddingVertical: 6,
    borderRadius: 20,
    backgroundColor: '#e0e0e0',
    marginRight: 8,
  },
  statusChipSelected: {
    backgroundColor: '#2563EB',
  },
  statusChipText: {
    fontSize: 13,
    color: '#666',
  },
  statusChipTextSelected: {
    color: '#fff',
  },
  listContent: {
    padding: 10,
  },
  card: {
    marginBottom: 10,
    elevation: 2,
  },
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 12,
  },
  orderNumber: {
    fontSize: 16,
    fontWeight: 'bold',
  },
  statusBadge: {
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 10,
  },
  statusText: {
    color: '#fff',
    fontSize: 12,
    fontWeight: '600',
  },
  cardBody: {
    gap: 6,
  },
  infoRow: {
    flexDirection: 'row',
  },
  label: {
    width: 80,
    color: '#666',
    fontSize: 14,
  },
  value: {
    flex: 1,
    color: '#333',
    fontSize: 14,
  },
  resultText: {
    fontWeight: '600',
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  loadingText: {
    marginTop: 10,
    color: '#666',
  },
  emptyContainer: {
    padding: 50,
    alignItems: 'center',
  },
  emptyText: {
    color: '#999',
    fontSize: 16,
  },
});
