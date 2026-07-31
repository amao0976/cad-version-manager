require Rails.root.join('app', 'uploaders', 'product_image_uploader.rb').to_s

class ProductImage < ApplicationRecord
  belongs_to :product

  mount_uploader :image, ::ProductImageUploader

  validates :image, presence: true, if: -> { persisted? && !marked_for_destruction? }

  scope :sorted, -> { order(:position, :id) }
  scope :covers, -> { where(is_cover: true) }

  before_save :ensure_cover
  after_destroy :reset_cover_if_needed

  def set_as_cover!
    return if is_cover?
    transaction do
      product.product_images.update_all(is_cover: false)
      update!(is_cover: true)
    end
  end

  private

  def ensure_cover
    return unless product
    return if product.product_images.exists?(is_cover: true)
    self.is_cover = true
  end

  def reset_cover_if_needed
    return unless is_cover?
    next_image = product.product_images.where.not(id: id).sorted.first
    next_image&.update!(is_cover: true)
  end
end
