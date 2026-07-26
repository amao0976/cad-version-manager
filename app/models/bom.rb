class Bom < ApplicationRecord
  belongs_to :design_project
  belongs_to :design_drawing
  belongs_to :created_by
end
