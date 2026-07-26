class DrawingApproval < ApplicationRecord
  belongs_to :design_drawing
  belongs_to :drawing_version
  belongs_to :approver, class_name: 'User'

  validates :status, presence: true, inclusion: { in: ['pending', 'approved', 'rejected'] }

  def self.statuses
    { pending: 'pending', approved: 'approved', rejected: 'rejected' }
  end

  def approve!(comment = nil)
    update(status: 'approved', comment: comment)
  end

  def reject!(comment = nil)
    update(status: 'rejected', comment: comment)
  end
end
