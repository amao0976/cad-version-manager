class Guide < ApplicationRecord
  belongs_to :guide_category, optional: true
  belongs_to :author, class_name: 'User', optional: true
  belongs_to :product, optional: true

  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/, message: '只能包含小写字母、数字和连字符' }
  validates :content_md, presence: true

  before_validation :generate_slug, on: :create
  before_save :render_markdown

  scope :published, -> { where(status: 'published') }
  scope :drafts, -> { where(status: 'draft') }
  scope :by_category, ->(slug) { joins(:guide_category).where(guide_categories: { slug: slug }) }
  scope :search, ->(keyword) { where('title LIKE :kw OR content_md LIKE :kw', kw: "%#{keyword}%") }

  STATUSES = {
    'draft' => '草稿',
    'published' => '已发布',
    'archived' => '已归档'
  }.freeze

  def status_label
    STATUSES[status] || status
  end

  def published?
    status == 'published'
  end

  def draft?
    status == 'draft'
  end

  def archive!
    update(status: 'archived')
  end

  def publish!
    update(status: 'published', published_at: Time.current)
  end

  def increment_view!
    increment!(:views_count)
  end

  def to_param
    slug
  end

  private

  def generate_slug
    return if slug.present?
    # 尝试从标题生成slug，如果失败则使用ID或时间戳
    generated = title.to_s.parameterize
    self.slug = generated.presence || "guide-#{SecureRandom.hex(8)}"
  end

  def render_markdown
    self.content_html = MarkdownRenderer.render(content_md)
  end
end
