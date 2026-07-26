class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :name, presence: true, length: { maximum: 255 }
  validates :role, presence: true, inclusion: { in: ['admin', 'manager', 'engineer', 'viewer'] }

  has_many :design_projects, foreign_key: :created_by_id, dependent: :nullify
  has_many :design_drawings, foreign_key: :created_by_id, dependent: :nullify
  has_many :drawing_versions, foreign_key: :uploaded_by_id, dependent: :nullify
  has_many :drawing_approvals, foreign_key: :approver_id, dependent: :nullify

  def self.roles
    { admin: 'admin', manager: 'manager', engineer: 'engineer', viewer: 'viewer' }
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
end
