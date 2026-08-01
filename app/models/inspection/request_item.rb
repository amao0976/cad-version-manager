class Inspection::RequestItem < ApplicationRecord
  self.table_name = 'inspection_request_items'

  belongs_to :inspection_request, class_name: 'Inspection::Request', optional: true, inverse_of: :items

  # 支持 accepts_nested_attributes_for 的别名
  def request_id
    inspection_request_id
  end

  def request_id=(value)
    self.inspection_request_id = value
  end

  validates :order_number, :style_number, :quantity, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :aql_level, inclusion: { in: AqlCalculator::AQL_LEVELS }
  validates :inspection_level, inclusion: { in: AqlCalculator::INSPECTION_LEVELS }

  before_save :calculate_aql

  INSPECTION_LEVELS = AqlCalculator::INSPECTION_LEVELS
  AQL_LEVELS = AqlCalculator::AQL_LEVELS

  def aql_label
    "AQL #{aql_level} (#{AqlCalculator::INSPECTION_LEVEL_LABELS[inspection_level] || inspection_level})"
  end

  def inspection_level_label
    AqlCalculator::INSPECTION_LEVEL_LABELS[inspection_level] || inspection_level
  end

  def aql_level_label
    aql_level
  end

  def sample_size_calculator
    AqlCalculator.calculate(quantity, aql_level, inspection_level)
  end

  private

  def calculate_aql
    result = AqlCalculator.calculate(quantity, aql_level, inspection_level)
    self.code_letter = result[:code_letter]
    self.sample_size = result[:sample_size]
    self.accept_qty = result[:accept_qty]
    self.reject_qty = result[:reject_qty]
  end
end
