import React, { useState, useEffect, useCallback } from 'react';
import { View, ScrollView, StyleSheet, Alert } from 'react-native';
import { Card, Text, Button, ActivityIndicator, Surface } from 'react-native-paper';
import { useRoute, useNavigation } from '@react-navigation/native';
import api from '../../services/api';

interface InspectionRequestItem {
  id: number;
  order_number: string;
  style_number: string;
  quantity: number;
  inspection_level: string;
  aql_level: string;
  sample_size: number;
}

interface InspectionRequestDetail {
  id: number;
  order_number: string;
  style_number: string;
  quantity: number;
  status: string;
  status_label: string;
  inspection_type: string;
  requested_date: string;
  result: string | null;
  remarks: string;
  supplier: { id: number; name: string } | null;
  product: { id: number; name: string; product_code: string } | null;
  items: InspectionRequestItem[];
  can_schedule: boolean;
  can_complete: boolean;
  can_cancel: boolean;
  created_at: string;
  updated_at: string;
}

export default function RequestDetailScreen() {
  const route = useRoute<any>();
  const navigation = useNavigation<any>();
  const { id } = route.params;
  
  const [request, setRequest] = useState<InspectionRequestDetail | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isProcessing, setIsProcessing] = useState(false);

  const loadRequest = useCallback(async () => {
    try {
      setIsLoading(true);
      const response = await api.get(`/inspection/requests/${id}`);
      setRequest(response.data.data || response.data);
    } catch (error) {
      console.error('加载验货申请详情失败:', error);
      Alert.alert('错误', '加载验货申请详情失败');
    } finally {
      setIsLoading(false);
    }
  }, [id]);

  useEffect(() => {
    loadRequest();
  }, [loadRequest]);

  const handleAction = async (action: 'schedule' | 'complete' | 'cancel') => {
    const actionText = {
      schedule: '排期',
      complete: '完成',
      cancel: '取消'
    }[action];

    Alert.alert(
      '确认操作',
      `确定要${actionText}此验货申请吗？`,
      [
        { text: '取消', style: 'cancel' },
        {
          text: '确定',
          style: 'destructive',
          onPress: async () => {
            try {
              setIsProcessing(true);
              await api.patch(`/inspection/requests/${id}/${action}`);
              Alert.alert('成功', `已${actionText}`);
              loadRequest();
            } catch (error: any) {
              const errorMessage = error.response?.data?.error || '操作失败';
              Alert.alert('错误', errorMessage);
            } finally {
              setIsProcessing(false);
            }
          },
        },
      ]
    );
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'pending': return '#f59e0b';
      case 'scheduled': return '#2563eb';
      case 'completed': return '#16a34a';
      case 'cancelled': return '#dc2626';
      default: return '#6b7280';
    }
  };

  if (isLoading) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color="#2563EB" />
        <Text style={styles.loadingText}>加载中...</Text>
      </View>
    );
  }

  if (!request) {
    return (
      <View style={styles.errorContainer}>
        <Text style={styles.errorText}>未找到验货申请</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <ScrollView contentContainerStyle={styles.content}>
        {/* 状态卡片 */}
        <Card style={styles.statusCard}>
          <Card.Content>
            <View style={styles.statusRow}>
              <Text style={styles.orderNumber}>{request.order_number}</Text>
              <View style={[styles.statusBadge, { backgroundColor: getStatusColor(request.status) }]}>
                <Text style={styles.statusText}>{request.status_label}</Text>
              </View>
            </View>
            
            {request.result && (
              <View style={[styles.resultBadge, { backgroundColor: request.result === 'PASS' ? '#16a34a' : '#dc2626' }]}>
                <Text style={styles.resultText}>
                  {request.result === 'PASS' ? '合格' : '不合格'}
                </Text>
              </View>
            )}
          </Card.Content>
        </Card>

        {/* 基本信息 */}
        <Card style={styles.card}>
          <Card.Content>
            <Text style={styles.sectionTitle}>基本信息</Text>
            <View style={styles.infoList}>
              <InfoRow label="订单号" value={request.order_number} />
              <InfoRow label="款号" value={request.style_number} />
              <InfoRow label="数量" value={request.quantity.toString()} />
              <InfoRow label="验货类型" value={request.inspection_type} />
              <InfoRow label="申请日期" value={new Date(request.requested_date).toLocaleDateString()} />
              <InfoRow label="供应商" value={request.supplier?.name || 'N/A'} />
              <InfoRow label="产品" value={request.product?.name || 'N/A'} />
            </View>
          </Card.Content>
        </Card>

        {/* 明细项 */}
        <Card style={styles.card}>
          <Card.Content>
            <Text style={styles.sectionTitle}>验货明细</Text>
            {request.items.map((item) => (
              <View key={item.id} style={styles.itemCard}>
                <View style={styles.itemRow}>
                  <Text style={styles.itemLabel}>订单号:</Text>
                  <Text style={styles.itemValue}>{item.order_number}</Text>
                </View>
                <View style={styles.itemRow}>
                  <Text style={styles.itemLabel}>款号:</Text>
                  <Text style={styles.itemValue}>{item.style_number}</Text>
                </View>
                <View style={styles.itemRow}>
                  <Text style={styles.itemLabel}>数量:</Text>
                  <Text style={styles.itemValue}>{item.quantity}</Text>
                </View>
                <View style={styles.itemRow}>
                  <Text style={styles.itemLabel}>检验水平:</Text>
                  <Text style={styles.itemValue}>{item.inspection_level}</Text>
                </View>
                <View style={styles.itemRow}>
                  <Text style={styles.itemLabel}>AQL:</Text>
                  <Text style={styles.itemValue}>{item.aql_level}</Text>
                </View>
              </View>
            ))}
          </Card.Content>
        </Card>

        {/* 备注 */}
        {request.remarks && (
          <Card style={styles.card}>
            <Card.Content>
              <Text style={styles.sectionTitle}>备注</Text>
              <Text style={styles.remarksText}>{request.remarks}</Text>
            </Card.Content>
          </Card>
        )}
      </ScrollView>

      {/* 操作按钮 */}
      <View style={styles.actionBar}>
        {request.can_schedule && (
          <Button
            mode="contained"
            onPress={() => handleAction('schedule')}
            loading={isProcessing}
            disabled={isProcessing}
            style={[styles.actionButton, { backgroundColor: '#f59e0b' }]}
          >
            排期
          </Button>
        )}
        {request.can_complete && (
          <Button
            mode="contained"
            onPress={() => handleAction('complete')}
            loading={isProcessing}
            disabled={isProcessing}
            style={[styles.actionButton, { backgroundColor: '#16a34a' }]}
          >
            完成
          </Button>
        )}
        {request.can_cancel && (
          <Button
            mode="contained"
            onPress={() => handleAction('cancel')}
            loading={isProcessing}
            disabled={isProcessing}
            style={[styles.actionButton, { backgroundColor: '#dc2626' }]}
          >
            取消
          </Button>
        )}
      </View>
    </View>
  );
}

function InfoRow({ label, value }: { label: string; value: string }) {
  return (
    <View style={styles.infoRow}>
      <Text style={styles.infoLabel}>{label}</Text>
      <Text style={styles.infoValue}>{value}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  content: {
    padding: 10,
    paddingBottom: 100,
  },
  statusCard: {
    marginBottom: 10,
    elevation: 3,
  },
  statusRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  orderNumber: {
    fontSize: 18,
    fontWeight: 'bold',
  },
  statusBadge: {
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 12,
  },
  statusText: {
    color: '#fff',
    fontSize: 13,
    fontWeight: '600',
  },
  resultBadge: {
    alignSelf: 'flex-start',
    marginTop: 10,
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 12,
  },
  resultText: {
    color: '#fff',
    fontSize: 14,
    fontWeight: 'bold',
  },
  card: {
    marginBottom: 10,
    elevation: 2,
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    marginBottom: 12,
    color: '#333',
  },
  infoList: {
    gap: 8,
  },
  infoRow: {
    flexDirection: 'row',
    paddingVertical: 4,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: '#e0e0e0',
  },
  infoLabel: {
    width: 100,
    color: '#666',
    fontSize: 14,
  },
  infoValue: {
    flex: 1,
    color: '#333',
    fontSize: 14,
  },
  itemCard: {
    backgroundColor: '#f8f9fa',
    padding: 12,
    borderRadius: 8,
    marginBottom: 10,
  },
  itemRow: {
    flexDirection: 'row',
    marginBottom: 4,
  },
  itemLabel: {
    width: 80,
    color: '#666',
    fontSize: 13,
  },
  itemValue: {
    flex: 1,
    color: '#333',
    fontSize: 13,
  },
  remarksText: {
    color: '#666',
    fontSize: 14,
    lineHeight: 20,
  },
  actionBar: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    flexDirection: 'row',
    justifyContent: 'center',
    gap: 10,
    padding: 15,
    backgroundColor: '#fff',
    borderTopWidth: 1,
    borderTopColor: '#e0e0e0',
    elevation: 8,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: -2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
  },
  actionButton: {
    flex: 1,
    paddingVertical: 8,
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
  errorContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  errorText: {
    color: '#999',
    fontSize: 16,
  },
});
