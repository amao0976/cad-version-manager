// 用户
export interface User {
  id: number;
  email: string;
  name: string;
  role: string;
  token: string;
}

// 验货申请明细项
export interface RequestItem {
  id: number;
  order_number: string;
  style_number: string;
  quantity: number;
  inspection_level: string;
  aql_level: string;
  sample_size?: number;
  accept_number?: number;
  reject_number?: number;
}

// 验货申请
export interface InspectionRequest {
  id: number;
  order_number: string;
  style_number: string;
  supplier_id: number;
  supplier?: { id: number; name: string };
  product_id?: number;
  product?: { id: number; name: string };
  inspection_type: string;
  requested_date: string;
  status: string;
  status_label: string;
  status_color: string;
  remarks?: string;
  items?: RequestItem[];
  can_schedule?: boolean;
  can_cancel?: boolean;
  created_by?: { id: number; name: string };
  created_at?: string;
}

// 验货记录
export interface InspectionRecord {
  id: number;
  order_no: string;
  reference_no: string;
  inspection_date: string;
  inspection_type: string;
  supplier_id: number;
  supplier?: { id: number; name: string };
  product_id?: number;
  product?: { id: number; name: string };
  order_quantity: number;
  shipment_quantity: number;
  major_defects?: number;
  minor_defects?: number;
  qty_rejected?: number;
  result: string;
  result_label?: string;
  qc_name?: string;
  comments?: string;
  has_report?: boolean;
  request?: { id: number; status: string; status_label: string };
  created_at?: string;
}

// 验货报告
export interface InspectionReport {
  id: number;
  inspection_record_id: number;
  status: string;
  summary?: string;
  images?: {
    product?: string[];
    defect?: string[];
    packaging?: string[];
    label?: string[];
  };
  created_at?: string;
  updated_at?: string;
}

// 供应商
export interface Supplier {
  id: number;
  name: string;
  short_name?: string;
  code: string;
  supplier_type: string;
  status: string;
  level?: string;
  contact_person?: string;
  phone?: string;
  address?: string;
}

// 选项数据
export interface NewOptions {
  suppliers: { id: number; name: string }[];
  products: { id: number; name: string }[];
  inspection_types?: string[];
  inspection_levels?: { value: string; label: string }[];
  aql_levels?: string[];
  requests?: { id: number; order_number: string }[];
}

// API 响应
export interface ApiResponse<T> {
  data: T;
  meta?: {
    total_count: number;
    page: number;
    per_page: number;
  };
  message?: string;
  redirect?: string;
}
