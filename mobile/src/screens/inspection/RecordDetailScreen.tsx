import React, { useState, useEffect, useCallback } from 'react';
import { View, ScrollView, StyleSheet, Alert, TouchableOpacity } from 'react-native';
import { Card, Text, Button, ActivityIndicator, IconButton } from 'react-native-paper';
import { useRoute, useNavigation } from '@react-navigation/native';
import api from '../../services/api';

interface InspectionRecordDetail {
  id: number;
  order_no: string;
  reference_no: string;
  inspection_date: string;
  requested_date: string;
  inspection_type: string;
  result: string | null;
  major_defects: number;
  minor_defects: number;
  qty_rejected: number;
  order_quantity: number;
  shipment_quantity: number;
  comments: string;
  product: { id: number; name: string; product_code: string; cover_image: string } | null;
  supplier: { id: number; name: string } | null;
  request: { id: number; status: string; status_label: string } | null;
  has_report: boolean;
}

export default function RecordDetailScreen() {
  const route = useRoute<any>();
  const navigation = useNavigation<any>();
  const { id } = route.params;
  
  const [record, setRecord] = useState<InspectionRecordDetail | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isCreatingReport, setIsCreatingReport] = useState(false);

  const loadRecord = useCallback(async () => {
    try {
      setIsLoading(true);
      const response = await api.get(`/inspection/records/${id}`);
      setRecord(response.data.data || response.data);
    } catch (error) {
      console.error('加载验货记录详情失败:', error);
      Alert.alert('错误', '加载验货记录详情失败');
    } finally {
      setIsLoading(false);
    }
  }, [id]);

  useEffect(() => {
    loadRecord();
  }, [loadRecord]);

  const handleCreateReport = async () => {
    Alert.alert(
      '创建验货报告',
      '确定要为这条验货记录创建报告吗？',
      [
        { text: '取消', style: 'cancel' },
        {
          text: '确定',
          onPress: async () => {
            try {
              setIsCreatingReport(true);
              const response = await api.post(`/inspection/records/${id}/create_report`);
              const reportData = response.data.data;
              Alert.alert('成功', '验货报告创建成功');
              navigation.navigate('Report', { id: reportData.id });
            } catch (error: any) {
              const errorMessage = error.response?.data?.error || '创建失败';
              Alert.alert('错误', errorMessage);
            } finally {
              setIsCreatingReport(false);
            }
          },
        },
      ]
    );
  };

  const handleViewReport = () => {
    navigation.navigate('Report', { id });
  };

  const getResultColor = (result: string | null) => {
    if (!result) return '#6b7280';
    return result === 'pass' ? '#16a34a' : '#dc2626';
  };

  const getResultLabel = (result: string | null) => {
    if (!result) return '待检验';
    return result === 'pass' ? '合格' : '不合格';
  };

  if (isLoading) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color="#2563EB" />
        <Text style={styles.loadingText}>加载中...</Text>
      </View>
    );
  }

  if (!record) {
    return (
      <View style={styles.errorContainer}>
        <Text style={styles.errorText}>未找到验货记录</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <ScrollView contentContainerStyle={styles.content}>
        {/* 结果卡片 */}
        <Card style={styles.resultCard}>
          <Card.Content>
            <View style={styles.resultRow}>
              <Text style={styles.orderNumber}>{record.order_no}</Text>
              <View style={[styles.resultBadge, { backgroundColor: getResultColor(record.result) }]}>
                <Text style={styles.resultText}>{getResultLabel(record.result)}</Text>
              </View>
            </View>
            
            {record.has_report && (
              <TouchableOpacity 
                style={styles.reportLink}
                onPress={handleViewReport}
              >
                <Text style={styles.reportLinkText}>📄 查看验货报告 →</Text>
              </TouchableOpacity>
            )}
            
            {!record.has_report && !record.result && (
              <Button
                mode="contained"
                onPress={handleCreateReport}
                loading={isCreatingReport}
                disabled={isCreatingReport}
                style={styles.createReportButton}
              >
                创建验货报告
              </Button>
            )}
          </Card.Content>
        </Card>

        {/* 基本信息 */}
        <Card style={styles.card}>
          <Card.Content>
            <Text style={styles.sectionTitle}>基本信息</Text>
            <View style={styles.infoList}>
              <InfoRow label="订单号" value={record.order_no} />
              <InfoRow label="参考号" value={record.reference_no} />
              <InfoRow label="验货类型" value={record.inspection_type} />
              <InfoRow label="验货日期" value={new Date(record.inspection_date).toLocaleDateString()} />
              <InfoRow label="申请日期" value={record.requested_date ? new Date(record.requested_date).toLocaleDateString() : 'N/A'} />
            </View>
          </Card.Content>
        </Card>

        {/* 数量统计 */}
        <Card style={styles.card}>
          <Card.Content>
            <Text style={styles.sectionTitle}>数量统计</Text>
            <View style={styles.quantityGrid}>
              <View style={styles.quantityItem}>
                <Text style={styles.quantityLabel}>订单数量</Text>
                <Text style={styles.quantityValue}>{record.order_quantity}</Text>
              </View>
              <View style={styles.quantityItem}>
                <Text style={styles.quantityLabel}>出货数量</Text>
                <Text style={styles.quantityValue}>{record.shipment_quantity}</Text>
              </View>
              <View style={[styles.quantityItem, record.major_defects > 0 && styles.defectWarning]}>
                <Text style={styles.quantityLabel}>大缺陷</Text>
                <Text style={styles.quantityValue}>{record.major_defects}</Text>
              </View>
              <View style={[styles.quantityItem, record.minor_defects > 0 && styles.defectWarning]}>
                <Text style={styles.quantityLabel}>小缺陷</Text>
                <Text style={styles.quantityValue}>{record.minor_defects}</Text>
              </View>
              <View style={[styles.quantityItem, record.qty_rejected > 0 && styles.defectDanger]}>
                <Text style={styles.quantityLabel}>拒收数量</Text>
                <Text style={styles.quantityValue}>{record.qty_rejected}</Text>
              </View>
            </View>
          </Card.Content>
        </Card>

        {/* 产品信息 */}
        {record.product && (
          <Card style={styles.card}>
            <Card.Content>
              <Text style={styles.sectionTitle}>产品信息</Text>
              <View style={styles.infoList}>
                <InfoRow label="产品名称" value={record.product.name} />
                <InfoRow label="产品编码" value={record.product.product_code} />
              </View>
            </Card.Content>
          </Card>
        )}

        {/* 供应商 */}
        {record.supplier && (
          <Card style={styles.card}>
            <Card.Content>
              <Text style={styles.sectionTitle}>供应商</Text>
              <InfoRow label="名称" value={record.supplier.name} />
            </Card.Content>
          </Card>
        )}

        {/* 备注 */}
        {record.comments && (
          <Card style={styles.card}>
            <Card.Content>
              <Text style={styles.sectionTitle}>备注</Text>
              <Text style={styles.remarksText}>{record.comments}</Text>
            </Card.Content>
          </Card>
        )}
      </ScrollView>
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
  },
  resultCard: {
    marginBottom: 10,
    elevation: 3,
  },
  resultRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 12,
  },
  orderNumber: {
    fontSize: 18,
    fontWeight: 'bold',
  },
  resultBadge: {
    paddingHorizontal: 14,
    paddingVertical: 6,
    borderRadius: 12,
  },
  resultText: {
    color: '#fff',
    fontSize: 14,
    fontWeight: 'bold',
  },
  reportLink: {
    alignSelf: 'flex-start',
    padding: 10,
    backgroundColor: '#dbeafe',
    borderRadius: 8,
  },
  reportLinkText: {
    color: '#2563EB',
    fontSize: 15,
    fontWeight: '600',
  },
  createReportButton: {
    marginTop: 10,
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
  quantityGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 10,
  },
  quantityItem: {
    width: '45%',
    backgroundColor: '#f8f9fa',
    padding: 12,
    borderRadius: 8,
    alignItems: 'center',
  },
  quantityLabel: {
    fontSize: 12,
    color: '#666',
    marginBottom: 4,
  },
  quantityValue: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#333',
  },
  defectWarning: {
    backgroundColor: '#fef3c7',
  },
  defectDanger: {
    backgroundColor: '#fee2e2',
  },
  remarksText: {
    color: '#666',
    fontSize: 14,
    lineHeight: 20,
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
