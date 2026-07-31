import React, { useState, useEffect, useCallback } from 'react';
import { View, FlatList, StyleSheet, TouchableOpacity, RefreshControl, ScrollView } from 'react-native';
import { Card, Text, Button, TextInput, ActivityIndicator } from 'react-native-paper';
import { useNavigation } from '@react-navigation/native';
import api from '../../services/api';

interface InspectionRecord {
  id: number;
  order_no: string;
  reference_no: string;
  inspection_date: string;
  inspection_type: string;
  result: string | null;
  major_defects: number;
  minor_defects: number;
  qty_rejected: number;
  order_quantity: number;
  comments: string;
  product: { id: number; name: string; product_code: string } | null;
  supplier: { id: number; name: string } | null;
  request: { id: number; status: string; status_label: string } | null;
  has_report: boolean;
}

export default function RecordListScreen() {
  const navigation = useNavigation<any>();
  const [records, setRecords] = useState<InspectionRecord[]>([]);
  const [filteredRecords, setFilteredRecords] = useState<InspectionRecord[]>([]);
  const [keyword, setKeyword] = useState('');
  const [selectedResult, setSelectedResult] = useState<string | null>(null);
  const [showPendingOnly, setShowPendingOnly] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const [isRefreshing, setIsRefreshing] = useState(false);

  const loadRecords = useCallback(async (pendingOnly = false) => {
    try {
      setIsLoading(true);
      let response;
      
      if (pendingOnly) {
        response = await api.get('/inspection/records/pending');
      } else {
        response = await api.get('/inspection/records');
      }
      
      const data = response.data.data || response.data;
      setRecords(Array.isArray(data) ? data : []);
    } catch (error) {
      console.error('加载验货记录失败:', error);
    } finally {
      setIsLoading(false);
    }
  }, []);

  const handleRefresh = async () => {
    setIsRefreshing(true);
    await loadRecords(showPendingOnly);
    setIsRefreshing(false);
  };

  useEffect(() => {
    loadRecords(showPendingOnly);
  }, [loadRecords, showPendingOnly]);

  useEffect(() => {
    let filtered = records;
    
    if (keyword) {
      filtered = filtered.filter(
        r => 
          r.order_no?.toLowerCase().includes(keyword.toLowerCase()) ||
          r.reference_no?.toLowerCase().includes(keyword.toLowerCase())
      );
    }
    
    if (selectedResult) {
      filtered = filtered.filter(r => r.result === selectedResult);
    }
    
    setFilteredRecords(filtered);
  }, [records, keyword, selectedResult]);

  const getResultColor = (result: string | null) => {
    if (!result) return '#6b7280';
    return result === 'pass' ? '#16a34a' : '#dc2626';
  };

  const getResultLabel = (result: string | null) => {
    if (!result) return '待检验';
    return result === 'pass' ? '合格' : '不合格';
  };

  const renderItem = ({ item }: { item: InspectionRecord }) => (
    <Card 
      style={styles.card} 
      onPress={() => navigation.navigate('RecordDetail', { id: item.id })}
    >
      <Card.Content>
        <View style={styles.cardHeader}>
          <Text style={styles.orderNumber}>{item.order_no}</Text>
          <View style={[styles.resultBadge, { backgroundColor: getResultColor(item.result) }]}>
            <Text style={styles.resultText}>{getResultLabel(item.result)}</Text>
          </View>
        </View>
        
        <View style={styles.cardBody}>
          <View style={styles.infoRow}>
            <Text style={styles.label}>产品:</Text>
            <Text style={styles.value}>{item.product?.name || 'N/A'}</Text>
          </View>
          <View style={styles.infoRow}>
            <Text style={styles.label}>类型:</Text>
            <Text style={styles.value}>{item.inspection_type}</Text>
          </View>
          <View style={styles.infoRow}>
            <Text style={styles.label}>日期:</Text>
            <Text style={styles.value}>{new Date(item.inspection_date).toLocaleDateString()}</Text>
          </View>
          <View style={styles.infoRow}>
            <Text style={styles.label}>缺陷:</Text>
            <Text style={[styles.value, item.major_defects > 0 && styles.defectWarning]}>
              大:{item.major_defects} 小:{item.minor_defects}
            </Text>
          </View>
          {item.has_report && (
            <View style={styles.reportBadge}>
              <Text style={styles.reportBadgeText}>📄 已有报告</Text>
            </View>
          )}
        </View>
      </Card.Content>
    </Card>
  );

  const renderFilterBar = () => (
    <View style={styles.filterContainer}>
      <TouchableOpacity
        style={[styles.pendingToggle, showPendingOnly && styles.pendingToggleActive]}
        onPress={() => setShowPendingOnly(!showPendingOnly)}
      >
        <Text style={[styles.pendingToggleText, showPendingOnly && styles.pendingToggleTextActive]}>
          {showPendingOnly ? '✓ 仅显示待处理' : '仅显示待处理'}
        </Text>
      </TouchableOpacity>
      
      <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.resultFilter}>
        {[
          { key: null, label: '全部' },
          { key: 'pass', label: '合格' },
          { key: 'fail', label: '不合格' },
          { key: '', label: '待检验' },
        ].map(result => (
          <TouchableOpacity
            key={result.key || 'all'}
            style={[
              styles.resultChip,
              selectedResult === result.key && styles.resultChipSelected
            ]}
            onPress={() => setSelectedResult(result.key)}
          >
            <Text style={[
              styles.resultChipText,
              selectedResult === result.key && styles.resultChipTextSelected
            ]}>
              {result.label}
            </Text>
          </TouchableOpacity>
        ))}
      </ScrollView>
    </View>
  );

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
          placeholder="搜索订单号或参考号"
          value={keyword}
          onChangeText={setKeyword}
          style={styles.searchInput}
          mode="outlined"
          left={<TextInput.Icon icon="magnify" />}
        />
      </View>
      
      {renderFilterBar()}
      
      <FlatList
        data={filteredRecords}
        renderItem={renderItem}
        keyExtractor={(item) => item.id.toString()}
        contentContainerStyle={styles.listContent}
        refreshControl={
          <RefreshControl refreshing={isRefreshing} onRefresh={handleRefresh} />
        }
        ListEmptyComponent={
          <View style={styles.emptyContainer}>
            <Text style={styles.emptyText}>暂无验货记录</Text>
          </View>
        }
      />
    </View>
  );
}

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
    gap: 8,
  },
  pendingToggle: {
    alignSelf: 'flex-start',
    paddingHorizontal: 14,
    paddingVertical: 6,
    borderRadius: 16,
    borderWidth: 1,
    borderColor: '#2563EB',
    backgroundColor: '#fff',
  },
  pendingToggleActive: {
    backgroundColor: '#2563EB',
  },
  pendingToggleText: {
    fontSize: 13,
    color: '#2563EB',
  },
  pendingToggleTextActive: {
    color: '#fff',
  },
  resultFilter: {
    flexGrow: 0,
  },
  resultChip: {
    paddingHorizontal: 14,
    paddingVertical: 6,
    borderRadius: 18,
    backgroundColor: '#e0e0e0',
    marginRight: 8,
  },
  resultChipSelected: {
    backgroundColor: '#2563EB',
  },
  resultChipText: {
    fontSize: 12,
    color: '#666',
  },
  resultChipTextSelected: {
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
    marginBottom: 10,
  },
  orderNumber: {
    fontSize: 16,
    fontWeight: 'bold',
  },
  resultBadge: {
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 10,
  },
  resultText: {
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
    width: 70,
    color: '#666',
    fontSize: 14,
  },
  value: {
    flex: 1,
    color: '#333',
    fontSize: 14,
  },
  defectWarning: {
    color: '#dc2626',
    fontWeight: '600',
  },
  reportBadge: {
    alignSelf: 'flex-start',
    marginTop: 6,
    paddingHorizontal: 10,
    paddingVertical: 4,
    backgroundColor: '#dbeafe',
    borderRadius: 8,
  },
  reportBadgeText: {
    color: '#2563EB',
    fontSize: 12,
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
