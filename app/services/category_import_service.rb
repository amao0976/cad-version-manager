require 'csv'

class CategoryImportService
  attr_reader :file, :errors, :imported_count, :updated_count

  def initialize(file)
    @file = file
    @errors = []
    @imported_count = 0
    @updated_count = 0
  end

  def call
    parse_and_import
  rescue StandardError => e
    @errors << "导入文件处理失败: #{e.message}"
  end

  def success?
    @errors.empty?
  end

  # 导出所有分类为CSV
  def self.export
    CSV.generate do |csv|
      csv << ['name', 'code', 'parent_code', 'sort_order', 'description']
      Category.order(:parent_id, :sort_order).each do |cat|
        csv << [
          cat.name,
          cat.code,
          cat.parent&.code,
          cat.sort_order,
          cat.description
        ]
      end
    end
  end

  private

  def parse_and_import
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

      rows.each_with_index do |row, index|
        import_row(row, index + 2)
      end
    rescue CSV::MalformedCSVError => e
      @errors << "CSV 文件格式错误: #{e.message}"
    rescue Encoding::UndefinedConversionError
      @errors << 'CSV 文件编码错误，请使用 UTF-8 编码'
    end
  end

  def validate_headers(headers)
    required_headers = [:name, :code]
    missing = required_headers - headers
    if missing.any?
      @errors << "CSV 文件缺少必需的列: #{missing.map(&:to_s).join(', ')}"
    end
  end

  def import_row(row, line_num)
    name = row[:name]&.strip
    code = row[:code]&.strip
    parent_code = row[:parent_code]&.strip
    sort_order = row[:sort_order]&.strip&.to_i || 0
    description = row[:description]&.strip

    return if name.blank? || code.blank?

    parent = parent_code.present? ? Category.find_by(code: parent_code) : nil
    if parent_code.present? && parent.nil?
      @errors << "第#{line_num}行: 找不到父分类编码 '#{parent_code}'"
      return
    end

    category = Category.find_by(code: code)
    if category
      if category.update(name: name, parent: parent, sort_order: sort_order, description: description)
        @updated_count += 1
      else
        @errors << "第#{line_num}行: #{category.errors.full_messages.join(', ')}"
      end
    else
      category = Category.new(name: name, code: code, parent: parent, sort_order: sort_order, description: description)
      if category.save
        @imported_count += 1
      else
        @errors << "第#{line_num}行: #{category.errors.full_messages.join(', ')}"
      end
    end
  end
end
