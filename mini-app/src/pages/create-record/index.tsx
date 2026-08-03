import React, { useState, useEffect } from 'react';
import { View, Text, Input, Textarea, Picker, Button } from '@tarojs/components';
import Taro, { useRouter } from '@tarojs/taro';
import { apiService } from '../../services/api';
import styles from './index.module.scss';

const INSPECTION_TYPES = ['首件检查', '中期检查', '尾期检查', '过程检查'];

function CreateRecordPage() {
  const router = useRouter();
  const presetRequestId = router.params.request_id;
  const [options, setOptions] = useState<any>(null);
  const [supplierIdx, setSupplierIdx] = useState(-1);
  const [productIdx, setProductIdx] = useState(-1);
  const [orderNo, setOrderNo] = useState('');
  const [referenceNo, setReferenceNo] = useState('');
  const [inspectionType, setInspectionType] = useState(0);
  const [inspectionDate, setInspectionDate] = useState('');
  const [orderQty, setOrderQty] = useState('');
  const [shipmentQty, setShipmentQty] = useState('');
  const [majorDefects, setMajorDefects] = useState('');
  const [minorDefects, setMinorDefects] = useState('');
  const [qtyRejected, setQtyRejected] = useState('');
  const [result, setResult] = useState('pending');
  const [comments, setComments] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    loadOptions();
  }, []);

  const loadOptions = async () => {
    try {
      const res = await apiService.inspectionRecords.newOptions();
      const opts = res.data;
      setOptions(opts);

      // 如果有预设的 request_id，自动加载验货申请信息
      if (presetRequestId) {
        try {
          const reqRes = await apiService.inspectionRequests.get(Number(presetRequestId));
          const req = reqRes.data;
          if (req) {
            const firstItem = req.items?.[0];
            setOrderNo(firstItem?.order_number || req.order_number || '');
            setReferenceNo(firstItem?.style_number || req.style_number || '');
            const typeIdx = INSPECTION_TYPES.indexOf(req.inspection_type);
            if (typeIdx >= 0) setInspectionType(typeIdx);
            if (req.supplier) {
              const idx = opts.suppliers?.findIndex((s: any) => s.id === req.supplier.id);
              if (idx >= 0) setSupplierIdx(idx);
            }
            if (req.product) {
              const idx = opts.products?.findIndex((p: any) => p.id === req.product.id);
              if (idx >= 0) setProductIdx(idx);
            }
            setOrderQty(firstItem?.quantity ? String(firstItem.quantity) : '');
          }
        } catch {
          // 忽略加载失败
        }
      }
    } catch (err) {
      setError('加载选项数据失败');
    }
  };

  const handleSubmit = async () => {
    if (!orderNo.trim()) {
      setError('请输入订单号');
      return;
    }
    if (supplierIdx < 0) {
      setError('请选择供应商');
      return;
    }
    if (!inspectionDate) {
      setError('请选择验货日期');
      return;
    }

    setError('');
    setLoading(true);
    try {
      const data: any = {
        order_no: orderNo,
        reference_no: referenceNo || undefined,
        inspection_type: INSPECTION_TYPES[inspectionType],
        inspection_date: inspectionDate,
        supplier_id: options.suppliers[supplierIdx].id,
        product_id: productIdx >= 0 ? options.products[productIdx].id : undefined,
        order_quantity: orderQty ? parseInt(orderQty) : undefined,
        shipment_quantity: shipmentQty ? parseInt(shipmentQty) : undefined,
        major_defects: majorDefects ? parseInt(majorDefects) : undefined,
        minor_defects: minorDefects ? parseInt(minorDefects) : undefined,
        qty_rejected: qtyRejected ? parseInt(qtyRejected) : undefined,
        result,
        comments: comments || undefined,
      };
      if (presetRequestId) {
        data.inspection_request_id = parseInt(presetRequestId);
      }
      await apiService.inspectionRecords.create(data);
      Taro.showToast({ title: '创建成功', icon: 'success' });
      setTimeout(() => Taro.navigateBack(), 500);
    } catch (err: any) {
      setError(err.message || '创建失败，请检查输入信息');
    } finally {
      setLoading(false);
    }
  };

  const suppliers = options?.suppliers || [];
  const products = options?.products || [];
  const today = new Date().toISOString().split('T')[0];

  return (
    <View className={styles.page}>
      <View className={styles.section}>
        <View className={styles.sectionTitle}><Text>基本信息</Text></View>
        <View className={styles.field}>
          <Text className={styles.label}>订单号 *</Text>
          <Input
            className={styles.input}
            placeholder="输入订单号"
            value={orderNo}
            onInput={(e) => setOrderNo(e.detail.value)}
          />
        </View>
        <View className={styles.field}>
          <Text className={styles.label}>款号</Text>
          <Input
            className={styles.input}
            placeholder="输入款号"
            value={referenceNo}
            onInput={(e) => setReferenceNo(e.detail.value)}
          />
        </View>
        <View className={styles.field}>
          <Text className={styles.label}>供应商 *</Text>
          <Picker
            mode="selector"
            range={suppliers}
            rangeKey="name"
            value={supplierIdx < 0 ? 0 : supplierIdx}
            onChange={(e) => setSupplierIdx(Number(e.detail.value))}
          >
            <View className={styles.picker}>
              <Text className={supplierIdx >= 0 ? styles.pickerText : styles.pickerPlaceholder}>
                {supplierIdx >= 0 ? suppliers[supplierIdx]?.name : '请选择供应商'}
              </Text>
              <Text>›</Text>
            </View>
          </Picker>
        </View>
        <View className={styles.field}>
          <Text className={styles.label}>验货类型 *</Text>
          <Picker
            mode="selector"
            range={INSPECTION_TYPES}
            value={inspectionType}
            onChange={(e) => setInspectionType(Number(e.detail.value))}
          >
            <View className={styles.picker}>
              <Text className={styles.pickerText}>{INSPECTION_TYPES[inspectionType]}</Text>
              <Text>›</Text>
            </View>
          </Picker>
        </View>
        <View className={styles.field}>
          <Text className={styles.label}>验货日期 *</Text>
          <Picker mode="date" value={inspectionDate || today} onChange={(e) => setInspectionDate(e.detail.value)}>
            <View className={styles.picker}>
              <Text className={inspectionDate ? styles.pickerText : styles.pickerPlaceholder}>
                {inspectionDate || '请选择日期'}
              </Text>
              <Text>›</Text>
            </View>
          </Picker>
        </View>
      </View>

      <View className={styles.section}>
        <View className={styles.sectionTitle}><Text>数量统计</Text></View>
        <View className={styles.field}>
          <Text className={styles.label}>订单数量</Text>
          <Input
            className={styles.input}
            type="number"
            placeholder="输入订单数量"
            value={orderQty}
            onInput={(e) => setOrderQty(e.detail.value)}
          />
        </View>
        <View className={styles.field}>
          <Text className={styles.label}>出货数量</Text>
          <Input
            className={styles.input}
            type="number"
            placeholder="输入出货数量"
            value={shipmentQty}
            onInput={(e) => setShipmentQty(e.detail.value)}
          />
        </View>
        <View className={styles.field}>
          <Text className={styles.label}>主要缺陷数</Text>
          <Input
            className={styles.input}
            type="number"
            placeholder="输入主要缺陷数"
            value={majorDefects}
            onInput={(e) => setMajorDefects(e.detail.value)}
          />
        </View>
        <View className={styles.field}>
          <Text className={styles.label}>次要缺陷数</Text>
          <Input
            className={styles.input}
            type="number"
            placeholder="输入次要缺陷数"
            value={minorDefects}
            onInput={(e) => setMinorDefects(e.detail.value)}
          />
        </View>
        <View className={styles.field}>
          <Text className={styles.label}>拒收数量</Text>
          <Input
            className={styles.input}
            type="number"
            placeholder="输入拒收数量"
            value={qtyRejected}
            onInput={(e) => setQtyRejected(e.detail.value)}
          />
        </View>
        <View className={styles.field}>
          <Text className={styles.label}>验货结果</Text>
          <Picker
            mode="selector"
            range={[
              { value: 'pending', label: '待检验' },
              { value: 'pass', label: '合格' },
              { value: 'fail', label: '不合格' },
            ]}
            rangeKey="label"
            value={['pending', 'pass', 'fail'].indexOf(result)}
            onChange={(e) => setResult(['pending', 'pass', 'fail'][Number(e.detail.value)])}
          >
            <View className={styles.picker}>
              <Text className={styles.pickerText}>
                {result === 'pass' ? '合格' : result === 'fail' ? '不合格' : '待检验'}
              </Text>
              <Text>›</Text>
            </View>
          </Picker>
        </View>
      </View>

      <View className={styles.section}>
        <View className={styles.sectionTitle}><Text>备注</Text></View>
        <Textarea
          className={styles.textarea}
          placeholder="输入备注信息"
          value={comments}
          onInput={(e) => setComments(e.detail.value)}
        />
      </View>

      {error && <Text className={styles.errorText}>{error}</Text>}

      <View className={styles.actionBar}>
        <Button className={styles.submitBtn} onClick={handleSubmit} loading={loading} disabled={loading}>
          {loading ? '提交中...' : '提交记录'}
        </Button>
      </View>
    </View>
  );
}

export default CreateRecordPage;
