class Inspection::Report < ApplicationRecord
  self.table_name = 'inspection_reports'

  belongs_to :inspection_record, class_name: 'Inspection::Record', foreign_key: 'inspection_id'

  has_many_attached :product_overview_images
  has_many_attached :label_hangtag_images
  has_many_attached :rfid_images
  has_many_attached :defect_detail_images

  serialize :size_table, coder: JSON

  validates :inspection_id, uniqueness: true

  include AASM

  aasm column: :status do
    state :draft, initial: true
    state :completed

    event :complete do
      transitions from: :draft, to: :completed
    end

    event :reopen do
      transitions from: :completed, to: :draft
    end
  end

  STATUSES = {
    'draft' => '草稿',
    'completed' => '已完成'
  }.freeze

  def status_label
    STATUSES[status] || status
  end

  def can_complete?
    status == 'draft'
  end

  def can_reopen?
    status == 'completed'
  end

  def size_columns
    size_table.is_a?(Hash) ? (size_table['columns'] || []) : []
  end

  def size_rows
    return [] unless size_table.is_a?(Hash)
    raw_rows = size_table['rows'] || []
    raw_rows.map { |row| normalize_row(row) }
  end

  def pass_fail_for(row, size_column)
    values = row['values'] && row['values'][size_column]
    return nil unless values && values['nominal'].present? && values['actual'].present?

    nominal = Float(values['nominal']) rescue nil
    actual = Float(values['actual']) rescue nil
    tolerance = Float(row['tolerance']) rescue 0

    return nil if nominal.nil? || actual.nil?
    (actual - nominal).abs <= tolerance ? 'pass' : 'fail'
  end

  def size_table_normalized
    return { 'columns' => [], 'rows' => [] } unless size_table.is_a?(Hash)
    { 'columns' => size_columns, 'rows' => size_rows }
  end

  def self.size_table_templates
    @@templates ||= YAML.load_file(Rails.root.join('config', 'size_table_templates.yml')).deep_symbolize_keys
  end

  def self.template_list
    size_table_templates.map do |key, tmpl|
      { key: key.to_s, name: tmpl[:name_zh] || tmpl[:name_en], measurement_points: tmpl[:measurement_points] }
    end
  end

  def self.apply_template(template_key, columns)
    tmpl = size_table_templates[template_key.to_sym]
    return nil unless tmpl

    rows = tmpl[:measurement_points].map do |mp|
      values = {}
      columns.each { |col| values[col] = { 'nominal' => '', 'actual' => '' } }
      { 'measurement_point' => mp[:measurement_point], 'tolerance' => mp[:tolerance].to_s, 'values' => values }
    end

    { 'columns' => columns, 'rows' => rows }
  end

  attr_accessor :size_table_json

  before_save :parse_size_table_json

  private

  def normalize_row(row)
    return row unless row['values'].is_a?(Array)

    new_values = {}
    size_columns.each_with_index do |col, idx|
      new_values[col] = { 'nominal' => (row['values'][idx] || '').to_s, 'actual' => '' }
    end

    { 'measurement_point' => row['measurement_point'], 'tolerance' => row['tolerance'] || '', 'values' => new_values }
  end

  def parse_size_table_json
    if size_table_json.present?
      self.size_table = JSON.parse(size_table_json)
    end
  end
end
