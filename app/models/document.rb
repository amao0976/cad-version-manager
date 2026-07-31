class Document < ApplicationRecord
  belongs_to :product, optional: true
  belongs_to :design_drawing, optional: true
  belongs_to :created_by, class_name: 'User', optional: true
  has_many :document_versions, dependent: :destroy

  validates :title, presence: true, length: { maximum: 255 }
  validates :doc_number, presence: true, uniqueness: true, length: { maximum: 50 }
  validates :doc_type, presence: true, inclusion: { in: -> { Document.doc_types.values } }
  validates :status, inclusion: { in: -> { Document.statuses.values } }

  before_validation :set_default_status

  def self.doc_types
    {
      '技术规格书' => 'spec',
      '测试报告' => 'test_report',
      '认证文件' => 'certification',
      '使用手册' => 'manual',
      '设计图纸' => 'drawing',
      'BOM文档' => 'bom',
      '工艺文件' => 'process',
      '其他' => 'other'
    }
  end

  def self.statuses
    {
      '草稿' => 'draft',
      '已提交' => 'submitted',
      '已审批' => 'approved',
      '已发布' => 'released',
      '已作废' => 'superseded'
    }
  end

  def doc_type_label
    self.class.doc_types.key(doc_type) || doc_type
  end

  def status_label
    self.class.statuses.key(status) || status
  end

  def latest_version
    document_versions.order(created_at: :desc).first
  end

  def released_versions
    document_versions.where(status: 'released').order(released_at: :desc)
  end

  private

  def set_default_status
    self.status ||= 'draft'
  end
end
