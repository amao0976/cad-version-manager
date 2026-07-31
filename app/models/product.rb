class Product < ApplicationRecord
  belongs_to :category
  belongs_to :design_drawing, optional: true
  belongs_to :main_material, class_name: 'Material', optional: true
  belongs_to :movement_category, class_name: 'Category', optional: true
  belongs_to :strap_category, class_name: 'Category', optional: true
  belongs_to :target_group_category, class_name: 'Category', optional: true
  has_many :variants, dependent: :destroy
  has_many :product_boms, dependent: :nullify
  has_many :batches, through: :variants
  has_many :serial_numbers, through: :variants
  has_many :lifecycle_histories, dependent: :destroy
  has_many :documents, dependent: :nullify
  has_many :product_images, dependent: :destroy
  has_many :inspection_requests, class_name: 'Inspection::Request', dependent: :nullify
  has_many :inspection_records, class_name: 'Inspection::Record', dependent: :nullify

  accepts_nested_attributes_for :product_images, allow_destroy: true, reject_if: :all_blank

  validates :name, presence: true, length: { maximum: 255 }
  validates :product_code, presence: true, uniqueness: true, length: { maximum: 50 }
  validates :status, presence: true, inclusion: { in: ['draft', 'published', 'offline'] }
  validates :lifecycle_state, presence: true, inclusion: { in: -> { Product.lifecycle_states.values } }

  # 产品主题枚举
  def self.themes
    {
      '金色主题' => 'gold',
      '银色主题' => 'silver',
      '玫瑰金主题' => 'rose_gold',
      '枪色主题' => 'gunmetal',
      '黑铑主题' => 'black_rhodium',
      '铑色主题' => 'rhodium',
      '古铜色主题' => 'bronze',
      '镍色主题' => 'nickel',
      '铬色主题' => 'chrome',
      '彩色主题' => 'rainbow',
      '黑色主题' => 'black',
      '白色主题' => 'white',
      '其他主题' => 'other'
    }
  end

  # PLM 生命周期状态
  def self.lifecycle_states
    {
      '概念' => 'concept',
      '设计' => 'design',
      '原型' => 'prototype',
      '试产' => 'pilot',
      '量产' => 'production',
      '退市' => 'phase_out',
      '废弃' => 'obsolete'
    }
  end

  # 允许的状态转换路径
  def self.state_transitions
    {
      'concept' => ['design'],
      'design' => ['prototype', 'concept'],
      'prototype' => ['pilot', 'design'],
      'pilot' => ['production', 'prototype'],
      'production' => ['phase_out'],
      'phase_out' => ['obsolete', 'production'],
      'obsolete' => []
    }
  end

  def theme_label
    self.class.themes.key(theme) || theme
  end

  def lifecycle_state_label
    self.class.lifecycle_states.key(lifecycle_state) || lifecycle_state
  end

  def can_transition_to?(target_state)
    self.class.state_transitions[lifecycle_state]&.include?(target_state)
  end

  def allowed_next_states
    self.class.state_transitions[lifecycle_state] || []
  end

  def transition_to!(new_state, user, remark = nil)
    return false unless can_transition_to?(new_state)

    old_state = lifecycle_state
    update!(lifecycle_state: new_state, lifecycle_updated_at: Time.current)
    lifecycle_histories.create!(
      from_state: old_state,
      to_state: new_state,
      changed_by: user,
      remark: remark
    )
    true
  end

  def publish
    update(status: 'published')
  end

  def offline
    update(status: 'offline')
  end

  def default_variant
    variants.first
  end

  def cover_image
    product_images.covers.sorted.first || product_images.sorted.first
  end

  def cover_image_url(version = :list)
    img = cover_image
    return nil unless img
    version == :original ? img.image.url : img.image.send(version).url
  end
end
