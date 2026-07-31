# CarrierWave 配置
CarrierWave.configure do |config|
  # 在 development / test 中使用本地文件系统存储
  config.storage = :file
  config.permissions = 0o644
  config.directory_permissions = 0o755
  # 确保文件名不使用 unicode 问题（使用 uploader 内部 secure_token）
  config.ignore_integrity_errors = true
  config.ignore_processing_errors = true
  config.ignore_download_errors = true
end
