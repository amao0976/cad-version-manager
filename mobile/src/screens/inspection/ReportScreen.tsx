import React, { useState, useEffect, useCallback, useRef } from 'react';
import { View, ScrollView, StyleSheet, Alert, TouchableOpacity, Image, Modal, Platform } from 'react-native';
import { Card, Text, Button, ActivityIndicator } from 'react-native-paper';
import { useRoute, useNavigation } from '@react-navigation/native';
import api from '../../services/api';

// 仅在原生平台导入相机相关模块
const CameraView = Platform.OS !== 'web' 
  ? require('expo-camera').CameraView 
  : null;
const useCameraPermissions = Platform.OS !== 'web' 
  ? require('expo-camera').useCameraPermissions 
  : null;

// 仅在原生平台导入图片选择器
const ImagePicker = Platform.OS !== 'web' 
  ? require('expo-image-picker') 
  : null;

interface ReportData {
  id: number;
  status: string;
  style_description: string;
  color: string;
  material_composition: string;
  size_range: string;
  summary: string;
  product_remarks: string;
  size_table: any;
  product_overview_images: string[];
  label_hangtag_images: string[];
  rfid_images: string[];
  defect_detail_images: string[];
  inspection_record: { id: number; order_no: string };
}

type ImageCategory = 'product_overview' | 'label_hangtag' | 'rfid' | 'defect_detail';

const CATEGORY_LABELS: Record<ImageCategory, string> = {
  product_overview: '产品外观',
  label_hangtag: '标签吊牌',
  rfid: 'RFID标签',
  defect_detail: '缺陷详情',
};

export default function ReportScreen() {
  const route = useRoute<any>();
  const navigation = useNavigation<any>();
  const { id } = route.params;
  
  const [report, setReport] = useState<ReportData | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isUploading, setIsUploading] = useState(false);
  const [activeCategory, setActiveCategory] = useState<ImageCategory>('product_overview');
  const [showCamera, setShowCamera] = useState(false);
  const [showImagePicker, setShowImagePicker] = useState(false);
  const [cameraPermission, setCameraPermission] = useState<any>(null);
  
  // Web 平台的文件选择
  const webFileInputRef = useRef<any>(null);

  const loadReport = useCallback(async () => {
    try {
      setIsLoading(true);
      const response = await api.get(`/inspection/reports/${id}`);
      setReport(response.data.data || response.data);
    } catch (error) {
      console.error('加载报告失败:', error);
      Alert.alert('错误', '加载报告失败');
    } finally {
      setIsLoading(false);
    }
  }, [id]);

  useEffect(() => {
    loadReport();
  }, [loadReport]);

  const requestCamera = async () => {
    if (Platform.OS === 'web') {
      // Web 平台使用文件选择
      if (webFileInputRef.current) {
        webFileInputRef.current.click();
      }
      return;
    }
    
    if (useCameraPermissions) {
      const { granted } = await useCameraPermissions.request();
      if (!granted) {
        Alert.alert('权限错误', '需要相机权限才能拍照');
        return;
      }
      setShowCamera(true);
    }
  };

  const takePhoto = async () => {
    if (ImagePicker) {
      try {
        const result = await ImagePicker.launchCameraAsync({
          mediaTypes: ImagePicker.MediaTypeOptions.Images,
          allowsEditing: true,
          quality: 0.8,
        });

        if (!result.canceled && result.assets) {
          await uploadImage(result.assets[0].uri);
        }
      } catch (error) {
        console.error('拍照失败:', error);
        Alert.alert('错误', '拍照失败');
      } finally {
        setShowCamera(false);
      }
    }
  };

  const pickFromGallery = async () => {
    if (ImagePicker) {
      try {
        const result = await ImagePicker.launchImageLibraryAsync({
          mediaTypes: ImagePicker.MediaTypeOptions.Images,
          allowsEditing: true,
          quality: 0.8,
        });

        if (!result.canceled && result.assets) {
          await uploadImage(result.assets[0].uri);
        }
      } catch (error) {
        console.error('选择图片失败:', error);
        Alert.alert('错误', '选择图片失败');
      } finally {
        setShowImagePicker(false);
      }
    }
  };

  // Web 平台处理文件选择
  const handleWebFileSelect = (event: any) => {
    const file = event.target.files?.[0];
    if (file) {
      const uri = URL.createObjectURL(file);
      uploadImage(uri, file);
    }
    // 清空选择，允许重复选择同一文件
    event.target.value = '';
  };

  const uploadImage = async (imageUri: string, webFile?: any) => {
    try {
      setIsUploading(true);
      
      if (webFile) {
        // Web 平台：使用 FormData 直接上传文件
        const formData = new FormData();
        formData.append('image', webFile);
        formData.append('category', activeCategory);
        
        await api.post(`/inspection/reports/${id}/upload_image`, formData, {
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        });
      } else {
        // 原生平台：使用 URI 上传
        await api.post(`/inspection/reports/${id}/upload_image`, {
          image: imageUri,
          category: activeCategory,
        });
      }
      
      Alert.alert('成功', '图片上传成功');
      loadReport();
    } catch (error) {
      console.error('上传图片失败:', error);
      Alert.alert('错误', '上传图片失败');
    } finally {
      setIsUploading(false);
    }
  };

  const getImagesForCategory = (category: ImageCategory): string[] => {
    if (!report) return [];
    switch (category) {
      case 'product_overview': return report.product_overview_images;
      case 'label_hangtag': return report.label_hangtag_images;
      case 'rfid': return report.rfid_images;
      case 'defect_detail': return report.defect_detail_images;
    }
  };

  const handleStatusAction = async (action: 'complete' | 'reopen') => {
    const actionText = action === 'complete' ? '完成报告' : '重新打开';
    Alert.alert('确认', `确定要${actionText}吗？`, [
      { text: '取消', style: 'cancel' },
      {
        text: '确定',
        onPress: async () => {
          try {
            await api.patch(`/inspection/reports/${id}/${action}`);
            Alert.alert('成功', `报告已${action === 'complete' ? '完成' : '重新打开'}`);
            loadReport();
          } catch (error: any) {
            Alert.alert('错误', error.response?.data?.error || '操作失败');
          }
        },
      },
    ]);
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'draft': return '#f59e0b';
      case 'completed': return '#16a34a';
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

  if (!report) {
    return (
      <View style={styles.errorContainer}>
        <Text style={styles.errorText}>未找到报告</Text>
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
              <Text style={styles.title}>验货报告</Text>
              <View style={[styles.statusBadge, { backgroundColor: getStatusColor(report.status) }]}>
                <Text style={styles.statusText}>
                  {report.status === 'draft' ? '草稿' : '已完成'}
                </Text>
              </View>
            </View>
            <Text style={styles.subtitle}>订单: {report.inspection_record.order_no}</Text>
          </Card.Content>
        </Card>

        {/* 基本信息 */}
        <Card style={styles.card}>
          <Card.Content>
            <Text style={styles.sectionTitle}>产品信息</Text>
            <View style={styles.infoList}>
              <InfoRow label="款式描述" value={report.style_description || 'N/A'} />
              <InfoRow label="颜色" value={report.color || 'N/A'} />
              <InfoRow label="材质" value={report.material_composition || 'N/A'} />
              <InfoRow label="尺寸范围" value={report.size_range || 'N/A'} />
            </View>
          </Card.Content>
        </Card>

        {/* 图片上传区 */}
        <Card style={styles.card}>
          <Card.Content>
            <Text style={styles.sectionTitle}>验货图片</Text>
            
            {/* 类别选择 */}
            <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.categoryTabs}>
              {(Object.keys(CATEGORY_LABELS) as ImageCategory[]).map((cat) => (
                <TouchableOpacity
                  key={cat}
                  style={[
                    styles.categoryTab,
                    activeCategory === cat && styles.categoryTabActive
                  ]}
                  onPress={() => setActiveCategory(cat)}
                >
                  <Text style={[
                    styles.categoryTabText,
                    activeCategory === cat && styles.categoryTabTextActive
                  ]}>
                    {CATEGORY_LABELS[cat]}
                  </Text>
                  <Text style={styles.imageCount}>
                    ({getImagesForCategory(cat).length})
                  </Text>
                </TouchableOpacity>
              ))}
            </ScrollView>

            {/* 已上传图片预览 */}
            {getImagesForCategory(activeCategory).length > 0 ? (
              <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.imagePreview}>
                {getImagesForCategory(activeCategory).map((uri, index) => (
                  <Image
                    key={index}
                    source={{ uri }}
                    style={styles.previewImage}
                  />
                ))}
              </ScrollView>
            ) : (
              <View style={styles.noImages}>
                <Text style={styles.noImagesText}>暂无图片，点击下方按钮上传</Text>
              </View>
            )}

            {/* 上传按钮 */}
            <View style={styles.uploadButtons}>
              {Platform.OS === 'web' ? (
                <>
                  {/* Web 平台使用文件选择 */}
                  <Button
                    mode="contained"
                    icon="image"
                    onPress={() => webFileInputRef.current?.click()}
                    style={styles.uploadButton}
                    loading={isUploading}
                    disabled={isUploading}
                  >
                    选择图片
                  </Button>
                  <input
                    ref={webFileInputRef}
                    type="file"
                    accept="image/*"
                    style={{ display: 'none' }}
                    onChange={handleWebFileSelect}
                  />
                </>
              ) : (
                <>
                  <Button
                    mode="contained"
                    icon="camera"
                    onPress={requestCamera}
                    style={styles.uploadButton}
                    loading={isUploading}
                    disabled={isUploading}
                  >
                    拍照
                  </Button>
                  <Button
                    mode="outlined"
                    icon="image"
                    onPress={() => setShowImagePicker(true)}
                    style={styles.uploadButton}
                    loading={isUploading}
                    disabled={isUploading}
                  >
                    相册
                  </Button>
                </>
              )}
            </View>
          </Card.Content>
        </Card>

        {/* 备注信息 */}
        {(report.summary || report.product_remarks) && (
          <Card style={styles.card}>
            <Card.Content>
              <Text style={styles.sectionTitle}>备注</Text>
              {report.summary && (
                <Text style={styles.remarkText}>
                  <Text style={styles.remarkLabel}>总结: </Text>
                  {report.summary}
                </Text>
              )}
              {report.product_remarks && (
                <Text style={styles.remarkText}>
                  <Text style={styles.remarkLabel}>产品备注: </Text>
                  {report.product_remarks}
                </Text>
              )}
            </Card.Content>
          </Card>
        )}

        {/* 状态操作 */}
        <View style={styles.actionSection}>
          {report.status === 'draft' && (
            <Button
              mode="contained"
              onPress={() => handleStatusAction('complete')}
              style={styles.actionButton}
            >
              标记为完成
            </Button>
          )}
          {report.status === 'completed' && (
            <Button
              mode="outlined"
              onPress={() => handleStatusAction('reopen')}
              style={styles.actionButton}
            >
              重新打开
            </Button>
          )}
        </View>
      </ScrollView>

      {/* 相机模态框（仅原生平台） */}
      {Platform.OS !== 'web' && showCamera && CameraView && (
        <Modal visible={showCamera} transparent={false} animationType="slide">
          <View style={styles.cameraContainer}>
            <CameraView style={styles.camera} facing="back" />
            <View style={styles.cameraControls}>
              <TouchableOpacity 
                style={styles.cameraButton}
                onPress={() => setShowCamera(false)}
              >
                <Text style={styles.cameraButtonText}>取消</Text>
              </TouchableOpacity>
              <TouchableOpacity 
                style={styles.captureButton}
                onPress={takePhoto}
              >
                <View style={styles.captureInner} />
              </TouchableOpacity>
              <View style={{ width: 60 }} />
            </View>
          </View>
        </Modal>
      )}

      {/* 图片选择模态框（仅原生平台） */}
      {Platform.OS !== 'web' && showImagePicker && (
        <Modal
          visible={showImagePicker}
          transparent
          animationType="fade"
          onRequestClose={() => setShowImagePicker(false)}
        >
          <View style={styles.modalOverlay}>
            <Card style={styles.modalCard}>
              <Card.Content>
                <Text style={styles.modalTitle}>选择图片来源</Text>
                <Button mode="contained" onPress={pickFromGallery} style={styles.modalButton}>
                  从相册选择
                </Button>
                <Button mode="outlined" onPress={() => setShowImagePicker(false)} style={styles.modalButton}>
                  取消
                </Button>
              </Card.Content>
            </Card>
          </View>
        </Modal>
      )}
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
    paddingBottom: 120,
  },
  statusCard: {
    marginBottom: 10,
    elevation: 3,
  },
  statusRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  title: {
    fontSize: 20,
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
  subtitle: {
    color: '#666',
    fontSize: 14,
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
  categoryTabs: {
    flexGrow: 0,
    marginBottom: 12,
  },
  categoryTab: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 20,
    backgroundColor: '#e0e0e0',
    marginRight: 8,
  },
  categoryTabActive: {
    backgroundColor: '#2563EB',
  },
  categoryTabText: {
    fontSize: 13,
    color: '#666',
    marginRight: 4,
  },
  categoryTabTextActive: {
    color: '#fff',
  },
  imageCount: {
    fontSize: 12,
    color: '#999',
  },
  imagePreview: {
    marginBottom: 12,
  },
  previewImage: {
    width: 120,
    height: 120,
    borderRadius: 8,
    marginRight: 8,
  },
  noImages: {
    height: 100,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#f8f9fa',
    borderRadius: 8,
    marginBottom: 12,
  },
  noImagesText: {
    color: '#999',
    fontSize: 14,
  },
  uploadButtons: {
    flexDirection: 'row',
    gap: 10,
  },
  uploadButton: {
    flex: 1,
  },
  remarkText: {
    fontSize: 14,
    color: '#666',
    lineHeight: 22,
    marginBottom: 8,
  },
  remarkLabel: {
    fontWeight: '600',
    color: '#333',
  },
  actionSection: {
    padding: 20,
    gap: 10,
  },
  actionButton: {
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
  cameraContainer: {
    flex: 1,
    backgroundColor: '#000',
  },
  camera: {
    flex: 1,
  },
  cameraControls: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 30,
    paddingBottom: 50,
    backgroundColor: 'rgba(0,0,0,0.5)',
  },
  cameraButton: {
    padding: 15,
  },
  cameraButtonText: {
    color: '#fff',
    fontSize: 16,
  },
  captureButton: {
    width: 70,
    height: 70,
    borderRadius: 35,
    borderWidth: 4,
    borderColor: '#fff',
    justifyContent: 'center',
    alignItems: 'center',
  },
  captureInner: {
    width: 55,
    height: 55,
    borderRadius: 27,
    backgroundColor: '#fff',
  },
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.5)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  modalCard: {
    width: '80%',
    maxWidth: 300,
  },
  modalTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 20,
    textAlign: 'center',
  },
  modalButton: {
    marginBottom: 10,
  },
});
