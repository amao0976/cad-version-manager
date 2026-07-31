require 'csv'

class ColorImportService
  attr_reader :file, :errors, :imported_count, :updated_count

  def initialize(file)
    @file = file
    @errors = []
    @imported_count = 0
    @updated_count = 0
  end

  def call
    parse_csv
    return if @errors.any?

    import_colors
  rescue StandardError => e
    @errors << "导入文件处理失败: #{e.message}"
  end

  def success?
    @errors.empty?
  end

  def preview_rows
    @preview_rows ||= []
  end

  private

  def parse_csv
    unless @file.present? && @file.respond_to?(:tempfile)
      @errors << '请选择有效的 CSV 文件'
      return
    end

    begin
      content = @file.tempfile.read.force_encoding('UTF-8')
      content = content.sub(/\A\uFEFF/, '') # Remove BOM if present
      rows = CSV.parse(content, headers: true, header_converters: :symbol)

      if rows.empty?
        @errors << 'CSV 文件为空'
        return
      end

      validate_headers(rows.headers)
      return if @errors.any?

      @preview_rows = rows.map { |row| normalize_row(row) }
    rescue CSV::MalformedCSVError => e
      @errors << "CSV 文件格式错误: #{e.message}"
    rescue Encoding::UndefinedConversionError
      @errors << 'CSV 文件编码错误，请使用 UTF-8 编码'
    end
  end

  def validate_headers(headers)
    required_headers = [:name, :code, :color_type]
    missing = required_headers - headers
    if missing.any?
      @errors << "CSV 文件缺少必需的列: #{missing.map { |h| header_name(h) }.join(', ')}"
    end
  end

  def header_name(symbol)
    { name: '颜色名称', code: '颜色编码', color_type: '颜色类型', hex_code: 'HEX代码', description: '描述', active: '启用状态' }[symbol] || symbol.to_s
  end

  def normalize_row(row)
    {
      name: row[:name]&.strip,
      code: row[:code]&.strip,
      color_type: normalize_color_type(row[:color_type]&.strip),
      hex_code: row[:hex_code]&.strip,
      description: row[:description]&.strip,
      active: parse_active(row[:active]&.strip)
    }
  end

  def normalize_color_type(type)
    return 'plating' if %w[plating electroplating 电镀 电镀颜色].include?(type.to_s.downcase)
    return 'fabric_leather' if %w[fabric_leather fabric leather 布料 皮料 布料皮料].include?(type.to_s.downcase)
    return 'other' if %w[other 其他].include?(type.to_s.downcase)
    type || 'other'
  end

  def parse_active(value)
    return true if %w[true 1 yes 是 enabled 启用].include?(value.to_s.downcase)
    return false if %w[false 0 no 否 disabled 停用].include?(value.to_s.downcase)
    true # default to active
  end

  def import_colors
    @preview_rows.each do |row|
      color = Color.find_by(code: row[:code])

      if color
        update_color(color, row)
      else
        create_color(row)
      end
    end
  end

  def update_color(color, row)
    if color.update(row)
      @updated_count += 1
    else
      @errors << "#{color.code}: #{color.errors.full_messages.join(', ')}"
    end
  end

  def create_color(row)
    color = Color.new(row)
    if color.save
      @imported_count += 1
    else
      @errors << "#{row[:code]}: #{color.errors.full_messages.join(', ')}"
    end
  end
end
