class GuideCategory < ApplicationRecord
  has_many :guides, dependent: :nullify

  before_validation :generate_slug, on: :create

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/, message: '只能包含小写字母、数字和连字符' }

  def to_param
    slug
  end

  private

  def generate_slug
    return if slug.present?
    # 使用英文转换或基于ID的slug
    self.slug = name.to_s.parameterize.presence || "category-#{Time.now.to_i}"
  end
end
