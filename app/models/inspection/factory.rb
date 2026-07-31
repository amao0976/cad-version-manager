class Inspection::Factory < ApplicationRecord
  self.table_name = 'factories'

  belongs_to :supplier
  has_many :inspection_records, class_name: 'Inspection::Record', foreign_key: :factory_id

  validates :name, presence: true
  validates :name, uniqueness: { scope: :supplier_id }

  def location
    [country, province, city].compact.join(' / ')
  end

  def display_name
    location.present? ? "#{name} (#{location})" : name
  end
end
