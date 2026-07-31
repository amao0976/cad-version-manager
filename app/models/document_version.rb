class DocumentVersion < ApplicationRecord
  belongs_to :document
  belongs_to :uploaded_by, class_name: 'User', optional: true
  belongs_to :approved_by, class_name: 'User', optional: true

  has_one_attached :file

  validates :version, presence: true, uniqueness: { scope: :document_id }
  validates :status, inclusion: { in: -> { Document.statuses.values } }

  before_validation :set_default_status

  def status_label
    Document.statuses.key(status) || status
  end

  def can_submit?
    status == 'draft'
  end

  def can_approve?
    status == 'submitted'
  end

  def can_release?
    status == 'approved'
  end

  def can_supersede?
    status == 'released'
  end

  def submit!(user)
    return false unless can_submit?
    update!(status: 'submitted', uploaded_by: user)
  end

  def approve!(user)
    return false unless can_approve?
    update!(status: 'approved', approved_by: user, approved_at: Time.current)
  end

  def release!(user)
    return false unless can_release?
    update!(status: 'released', released_at: Time.current)
    # 将旧版本标记为作废
    document.document_versions
      .where(status: 'released')
      .where.not(id: id)
      .update_all(status: 'superseded')
    document.update!(status: 'released', current_version: version)
  end

  private

  def set_default_status
    self.status ||= 'draft'
  end
end
