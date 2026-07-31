import React, { useState, useEffect, useCallback } from 'react';
import { View, FlatList, StyleSheet, RefreshControl } from 'react-native';
import { Card, Text, TextInput, ActivityIndicator } from 'react-native-paper';
import api from '../../services/api';

interface Supplier {
  id: number;
  code: string;
  name: string;
  supplier_type: string;
  contact_name: string;
  contact_phone: string;
  status: string;
}

export default function SuppliersScreen() {
  const [suppliers, setSuppliers] = useState<Supplier[]>([]);
  const [filteredSuppliers, setFilteredSuppliers] = useState<Supplier[]>([]);
  const [keyword, setKeyword] = useState('');
  const [isLoading, setIsLoading] = useState(true);
  const [isRefreshing, setIsRefreshing] = useState(false);

  const loadSuppliers = useCallback(async () => {
    try {
      setIsLoading(true);
      const response = await api.get('/suppliers');
      setSuppliers(response.data.data || response.data);
    } catch (error) {
      console.error('加载供应商列表失败:', error);
    } finally {
      setIsLoading(false);
    }
  }, []);

  const handleRefresh = async () => {
    setIsRefreshing(true);
    await loadSuppliers();
    setIsRefreshing(false);
  };

  useEffect(() => {
    loadSuppliers();
  }, [loadSuppliers]);

  useEffect(() => {
    if (keyword) {
      const filtered = suppliers.filter(
        s => 
          s.name?.toLowerCase().includes(keyword.toLowerCase()) ||
          s.code?.toLowerCase().includes(keyword.toLowerCase())
      );
      setFilteredSuppliers(filtered);
    } else {
      setFilteredSuppliers(suppliers);
    }
  }, [suppliers, keyword]);

  const getTypeLabel = (type: string) => {
    const types: Record<string, string> = {
      'manufacturer': '制造商',
      'factory': '工厂',
      'material': '材料供应商',
      'accessory': '配件供应商',
      'other': '其他',
    };
    return types[type] || type || '未知';
  };

  const getStatusColor = (status: string) => {
    return status === 'active' ? '#16a34a' : '#9ca3af';
  };

  const renderItem = ({ item }: { item: Supplier }) => (
    <Card style={styles.card}>
      <Card.Content>
        <View style={styles.cardHeader}>
          <Text style={styles.supplierName}>{item.name}</Text>
          <View style={[styles.statusBadge, { backgroundColor: getStatusColor(item.status) }]}>
            <Text style={styles.statusText}>{item.status === 'active' ? '活跃' : '停用'}</Text>
          </View>
        </View>
        
        <View style={styles.cardBody}>
          <View style={styles.infoRow}>
            <Text style={styles.label}>编码:</Text>
            <Text style={styles.value}>{item.code}</Text>
          </View>
          <View style={styles.infoRow}>
            <Text style={styles.label}>类型:</Text>
            <Text style={styles.value}>{getTypeLabel(item.supplier_type)}</Text>
          </View>
          <View style={styles.infoRow}>
            <Text style={styles.label}>联系人:</Text>
            <Text style={styles.value}>{item.contact_name || 'N/A'}</Text>
          </View>
          <View style={styles.infoRow}>
            <Text style={styles.label}>电话:</Text>
            <Text style={styles.value}>{item.contact_phone || 'N/A'}</Text>
          </View>
        </View>
      </Card.Content>
    </Card>
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
          placeholder="搜索供应商名称或编码"
          value={keyword}
          onChangeText={setKeyword}
          style={styles.searchInput}
          mode="outlined"
          left={<TextInput.Icon icon="magnify" />}
        />
      </View>
      
      <FlatList
        data={filteredSuppliers}
        renderItem={renderItem}
        keyExtractor={(item) => item.id.toString()}
        contentContainerStyle={styles.listContent}
        refreshControl={
          <RefreshControl refreshing={isRefreshing} onRefresh={handleRefresh} />
        }
        ListEmptyComponent={
          <View style={styles.emptyContainer}>
            <Text style={styles.emptyText}>暂无供应商</Text>
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
  supplierName: {
    fontSize: 17,
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
    width: 70,
    color: '#666',
    fontSize: 14,
  },
  value: {
    flex: 1,
    color: '#333',
    fontSize: 14,
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
