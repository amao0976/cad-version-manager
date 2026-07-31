class Inspection::Record < ApplicationRecord
  self.table_name = 'inspections'

  belongs_to :product, optional: true
  belongs_to :supplier, optional: true
  belongs_to :factory, optional: true
  belongs_to :inspection_request, class_name: 'Inspection::Request', optional: true
  has_one :report, class_name: 'Inspection::Report', foreign_key: :inspection_id, dependent: :destroy

  validates :inspection_date, :order_no, :reference_no, presence: true
  validates :week, numericality: { only_integer: true, greater_than: 0 }, allow_blank: true
  validates :order_quantity, :shipment_quantity, :major_defects, :minor_defects, :qty_rejected,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_blank: true

  RESULTS = {
    'pass' => '合格',
    'fail' => '不合格',
    'conditional' => '有条件通过'
  }.freeze

  INSPECTION_TYPES = %w[中期检查 尾期检查 首件检查 过程检查].freeze

  def result_label
    RESULTS[result] || result
  end

  def passed?
    result == 'pass'
  end

  def failed?
    result == 'fail'
  end

  def defect_rate
    return 0 if shipment_quantity.to_i == 0
    ((major_defects.to_i + minor_defects.to_i).to_f / shipment_quantity * 100).round(2)
  end

  def status_label
    result_label
  end

  private

  before_save :auto_calculate_week
  before_save :sync_supplier_factory_info

  def auto_calculate_week
    if inspection_date.present? && week.blank?
      self.week = iso_week_number(inspection_date)
    end
  end

  def sync_supplier_factory_info
    if factory.present?
      self.supplier ||= factory.supplier
      self.country = factory.country
      self.province = factory.province
      self.city = factory.city
    end
    if supplier.present?
      self.supplier_name = supplier.name
      self.supplier_category = supplier.category if supplier.respond_to?(:category)
    end
    if factory.present?
      self.factory_name = factory.name
    end
  end

  def iso_week_number(date)
    d = date
    day_of_week = (d.wday + 6) % 7
    thursday = d - day_of_week + 3
    year_start = Date.new(thursday.year, 1, 4)
    first_thursday = year_start - ((year_start.wday + 6) % 7) + 3
    1 + ((thursday - first_thursday) / 7).to_i
  end
end
