class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :timeoutable, :trackable

  validates :name, presence: true, length: { maximum: 255 }
  validates :role, presence: true, inclusion: { in: ['admin', 'manager', 'engineer', 'viewer', 'qc', 'supplier'] }

  belongs_to :supplier, optional: true

  has_many :design_projects, foreign_key: :created_by_id, dependent: :nullify
  has_many :design_drawings, foreign_key: :created_by_id, dependent: :nullify
  has_many :drawing_versions, foreign_key: :uploaded_by_id, dependent: :nullify
  has_many :drawing_approvals, foreign_key: :approver_id, dependent: :nullify

  def self.roles
    { admin: '管理员', manager: '经理', engineer: '工程师', viewer: '查看者', qc: 'QC', supplier: '供应商' }
  end

  def admin?
    role == 'admin'
  end

  def manager?
    role == 'manager' || admin?
  end

  def engineer?
    role == 'engineer' || manager?
  end

  def viewer?
    role == 'viewer' || engineer?
  end

  def qc?
    role == 'qc'
  end

  def supplier?
    role == 'supplier'
  end

  def supplier_role?
    role == 'supplier'
  end

  def inspector?
    qc? || admin?
  end
end
