import React, { useState, useEffect } from 'react';
import { View, Text, Input, Textarea, Picker, Button } from '@tarojs/components';
import Taro from '@tarojs/taro';
import { apiService } from '../../services/api';
import styles from './index.module.scss';

const INSPECTION_TYPES = ['首件检查', '中期检查', '尾期检查', '过程检查'];
const INSPECTION_LEVELS = [
  { value: 'I', label: '特殊检验水平 I' },
  { value: 'II', label: '一般检验水平 II' },
  { value: 'III', label: '特殊检验水平 III' },
];
const AQL_LEVELS = ['1.0', '1.5', '2.5', '4.0'];

interface Item {
  order_number: string;
  style_number: string;
  quantity: string;
  inspection_level: string;
  aql_level: string;
}

function CreateRequestPage() {
  const [options, setOptions] = useState<any>(null);
  const [supplierIdx, setSupplierIdx] = useState(-1);
  const [productIdx, setProductIdx] = useState(-1);
  const [inspectionType, setInspectionType] = useState(0);
  const [requestedDate, setRequestedDate] = useState('');
  const [remarks, setRemarks] = useState('');
  const [items, setItems] = useState<Item[]>([
    { order_number: '', style_number: '', quantity: '', inspection_level: 'II', aql_level: '2.5' },
  ]);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    loadOptions();
  }, []);

  const loadOptions = async () => {
    try {
      const res = await apiService.inspectionRequests.newOptions();
      setOptions(res.data);
    } catch (err) {
      console.error('[CreateRequest] 加载选项失败:', err);
    }
  };

  const handleAddItem = () => {
    setItems([
      ...items,
      { order_number: '', style_number: '', quantity: '', inspection_level: 'II', aql_level: '2.5' },
    ]);
  };

  const handleRemoveItem = (idx: number) => {
    setItems(items.filter((_, i) => i !== idx));
  };

  const handleItemChange = (idx: number, field: keyof Item, value: string) => {
    const newItems = [...items];
    newItems[idx] = { ...newItems[idx], [field]: value };
    setItems(newItems);
  };

  const onDateChange = (e) => {
    setRequestedDate(e.detail.value);
  };

  const handleSubmit = async () => {
    if (supplierIdx < 0) {
      setError('请选择供应商');
      return;
    }
    if (!requestedDate) {
      setError('请选择申请日期');
      return;
    }
    for (const item of items) {
      if (!item.order_number || !item.style_number || !item.quantity) {
        setError('请填写完整的明细项（订单号、款号、数量）');
        return;
      }
    }

    setError('');
    setLoading(true);
    try {
      const data = {
        supplier_id: options.suppliers[supplierIdx].id,
        product_id: productIdx >= 0 ? options.products[productIdx].id : undefined,
        inspection_type: INSPECTION_TYPES[inspectionType],
        requested_date: requestedDate,
        remarks: remarks || undefined,
        items_attributes: items.map((i) => ({
          order_number: i.order_number,
          style_number: i.style_number,
          quantity: parseInt(i.quantity),
          inspection_level: i.inspection_level,
          aql_level: i.aql_level,
        })),
      };
      await apiService.inspectionRequests.create(data);
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
          <Text className={styles.label}>产品</Text>
          <Picker
            mode="selector"
            range={products}
            rangeKey="name"
            value={productIdx < 0 ? 0 : productIdx}
            onChange={(e) => setProductIdx(Number(e.detail.value))}
          >
            <View className={styles.picker}>
              <Text className={productIdx >= 0 ? styles.pickerText : styles.pickerPlaceholder}>
                {productIdx >= 0 ? products[productIdx]?.name : '请选择产品（可选）'}
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
          <Text className={styles.label}>申请日期 *</Text>
          <Picker mode="date" value={requestedDate || today} onChange={onDateChange}>
            <View className={styles.picker}>
              <Text className={requestedDate ? styles.pickerText : styles.pickerPlaceholder}>
                {requestedDate || '请选择日期'}
              </Text>
              <Text>›</Text>
            </View>
          </Picker>
        </View>
        <View className={styles.field}>
          <Text className={styles.label}>备注</Text>
          <Textarea
            className={styles.textarea}
            placeholder="选填"
            value={remarks}
            onInput={(e) => setRemarks(e.detail.value)}
          />
        </View>
      </View>

      <View className={styles.section}>
        <View className={styles.sectionTitle}><Text>明细项</Text></View>
        {items.map((item, idx) => (
          <View key={idx} className={styles.itemCard}>
            {items.length > 1 && (
              <View className={styles.itemHeader}>
                <Text className={styles.itemTitle}>明细 {idx + 1}</Text>
                <Text className={styles.removeItem} onClick={() => handleRemoveItem(idx)}>删除</Text>
              </View>
            )}
            <View className={styles.field}>
              <Text className={styles.label}>订单号 *</Text>
              <Input
                className={styles.input}
                placeholder="输入订单号"
                value={item.order_number}
                onInput={(e) => handleItemChange(idx, 'order_number', e.detail.value)}
              />
            </View>
            <View className={styles.field}>
              <Text className={styles.label}>款号 *</Text>
              <Input
                className={styles.input}
                placeholder="输入款号"
                value={item.style_number}
                onInput={(e) => handleItemChange(idx, 'style_number', e.detail.value)}
              />
            </View>
            <View className={styles.field}>
              <Text className={styles.label}>数量 *</Text>
              <Input
                className={styles.input}
                type="number"
                placeholder="输入数量"
                value={item.quantity}
                onInput={(e) => handleItemChange(idx, 'quantity', e.detail.value)}
              />
            </View>
            <View className={styles.field}>
              <Text className={styles.label}>检验水平</Text>
              <Picker
                mode="selector"
                range={INSPECTION_LEVELS}
                rangeKey="label"
                value={INSPECTION_LEVELS.findIndex((l) => l.value === item.inspection_level)}
                onChange={(e) => handleItemChange(idx, 'inspection_level', INSPECTION_LEVELS[Number(e.detail.value)].value)}
              >
                <View className={styles.picker}>
                  <Text className={styles.pickerText}>
                    {INSPECTION_LEVELS.find((l) => l.value === item.inspection_level)?.label || '选择检验水平'}
                  </Text>
                  <Text>›</Text>
                </View>
              </Picker>
            </View>
            <View className={styles.field}>
              <Text className={styles.label}>AQL</Text>
              <Picker
                mode="selector"
                range={AQL_LEVELS}
                value={AQL_LEVELS.indexOf(item.aql_level)}
                onChange={(e) => handleItemChange(idx, 'aql_level', AQL_LEVELS[Number(e.detail.value)])}
              >
                <View className={styles.picker}>
                  <Text className={styles.pickerText}>{item.aql_level || '选择AQL'}</Text>
                  <Text>›</Text>
                </View>
              </Picker>
            </View>
          </View>
        ))}
        <Button className={styles.addItemBtn} onClick={handleAddItem}>
          + 添加明细项
        </Button>
      </View>

      {error && <Text className={styles.errorText}>{error}</Text>}

      <View className={styles.actionBar}>
        <Button className={styles.submitBtn} onClick={handleSubmit} loading={loading} disabled={loading}>
          {loading ? '提交中...' : '提交申请'}
        </Button>
      </View>
    </View>
  );
}

export default CreateRequestPage;
