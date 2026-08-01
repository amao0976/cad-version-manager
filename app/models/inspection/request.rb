class Inspection::Request < ApplicationRecord
  self.table_name = 'inspection_requests'

  belongs_to :product, optional: true
  belongs_to :supplier
  belongs_to :factory, optional: true
  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :inspection_record, class_name: 'Inspection::Record', foreign_key: 'inspection_id', optional: true

  has_many :items, class_name: 'Inspection::RequestItem', foreign_key: :inspection_request_id, dependent: :destroy
  has_many :inspection_records, class_name: 'Inspection::Record', foreign_key: :inspection_request_id, dependent: :nullify

  has_many_attached :approval_screenshots

  accepts_nested_attributes_for :items, allow_destroy: true, reject_if: :all_blank

  validates :requested_date, :supplier_id, presence: true
  validates :inspection_type, presence: true, inclusion: { in: %w[中期检查 尾期检查 首件检查 过程检查] }, on: :create
  validate :must_have_at_least_one_item

  before_save :sync_names, :sync_primary_fields

  include AASM

  aasm column: :status do
    state :pending, initial: true
    state :scheduled
    state :cancelled

    event :schedule do
      transitions from: :pending, to: :scheduled
    end

    event :cancel do
      transitions from: [:pending, :scheduled], to: :cancelled
    end
  end

  STATUSES = {
    'pending' => '待处理',
    'scheduled' => '已排期',
    'cancelled' => '已取消'
  }.freeze

  def status_label
    STATUSES[status] || status
  end

  def status_color
    { 'pending' => '#f59e0b', 'scheduled' => '#2563eb', 'cancelled' => '#dc2626' }[status] || '#6b7280'
  end

  def total_quantity
    items.sum(:quantity)
  end

  def total_sample_size
    items.sum(:sample_size)
  end

  def item_count
    items.count
  end

  def may_update?
    status == 'pending'
  end

  def can_review?
    status == 'pending'
  end

  def can_create_inspection?
    result == 'PASS' && approval_screenshots.attached? && status == 'pending'
  end

  private

  def must_have_at_least_one_item
    if items.reject(&:marked_for_destruction?).empty?
      errors.add(:base, '至少需要一个明细项')
    end
  end

  def sync_names
    self.supplier_name = supplier.name if supplier.present?
    self.factory_name = factory.name if factory.present?
  end

  def sync_primary_fields
    first_item = items.reject(&:marked_for_destruction?).first
    if first_item
      self.order_number = first_item.order_number
      self.style_number = first_item.style_number
      self.quantity = first_item.quantity
    end
  end
end
