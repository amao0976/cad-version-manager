// 类型定义

export interface InspectionRequest {
  id: number;
  order_number: string;
  style_number: string;
  quantity: number;
  status: 'pending' | 'scheduled' | 'completed' | 'cancelled';
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

export interface InspectionRequestItem {
  id: number;
  order_number: string;
  style_number: string;
  quantity: number;
  inspection_level: string;
  aql_level: string;
  sample_size: number;
}

export interface InspectionRecord {
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
  shipment_quantity: number;
  comments: string;
  product: { id: number; name: string; product_code: string; cover_image: string } | null;
  supplier: { id: number; name: string } | null;
  request: { id: number; status: string; status_label: string } | null;
  has_report: boolean;
  created_at: string;
  updated_at: string;
}

export interface InspectionReport {
  id: number;
  status: 'draft' | 'completed';
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
  created_at: string;
  updated_at: string;
}

export interface Supplier {
  id: number;
  code: string;
  name: string;
  supplier_type: string;
  contact_name: string;
  contact_phone: string;
  status: string;
}

export interface User {
  id: number;
  email: string;
  name: string;
  role: string;
}
