require 'carrierwave'

class ProductImageUploader < CarrierWave::Uploader::Base
  # 选择存储方式
  storage :file

  # 上传文件存放目录
  def store_dir
    "uploads/products/#{model.product_id}/#{model.class.to_s.underscore}/#{model.id}"
  end

  # 默认图片
  def default_url(*_args)
    "/images/fallback/#{model.class.to_s.underscore}/#{version_name || 'default'}_product.png"
  end

  # 允许上传的扩展名
  def extension_allowlist
    %w[jpg jpeg gif png webp]
  end

  # 覆盖文件名以避免乱码问题
  def filename
    if original_filename.present? && !defined?(@_filename)
      @_filename = "#{secure_token}.#{file.extension}"
    end
    @_filename || super
  end

  protected

  def secure_token
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) || model.instance_variable_set(var, SecureRandom.hex(8))
  end
end
