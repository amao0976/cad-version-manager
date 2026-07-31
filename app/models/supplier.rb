class Supplier < ApplicationRecord
  has_many :bom_items, dependent: :nullify
  has_many :factories, class_name: 'Inspection::Factory', foreign_key: :supplier_id
  has_many :inspection_requests, class_name: 'Inspection::Request'
  has_many :inspection_records, class_name: 'Inspection::Record'

  validates :name, presence: true, length: { maximum: 200 }
  validates :code, presence: true, length: { maximum: 50 }, uniqueness: true
  validates :short_name, length: { maximum: 100 }
  validates :contact_person, length: { maximum: 50 }
  validates :phone, length: { maximum: 50 }
  validates :email, length: { maximum: 100 }
  validates :address, length: { maximum: 300 }
  validates :supplier_type, inclusion: { in: %w[raw_material parts outsourcing packaging logistics] }
  validates :status, inclusion: { in: %w[active inactive blacklisted] }
  validates :level, inclusion: { in: %w[a b c] }

  scope :active, -> { where(status: 'active') }

  def self.supplier_types
    {
      'raw_material' => '原材料供应商',
      'parts' => '零部件供应商',
      'outsourcing' => '外协加工厂',
      'packaging' => '包装供应商',
      'logistics' => '物流服务商'
    }
  end

  def self.statuses
    {
      'active' => '合作中',
      'inactive' => '已停用',
      'blacklisted' => '黑名单'
    }
  end

  def self.levels
    {
      'a' => 'A级(战略)',
      'b' => 'B级(普通)',
      'c' => 'C级(备选)'
    }
  end

  def display_status
    self.class.statuses[status] || status
  end

  def display_type
    self.class.supplier_types[supplier_type] || supplier_type
  end

  def display_level
    self.class.levels[level] || level
  end
end
