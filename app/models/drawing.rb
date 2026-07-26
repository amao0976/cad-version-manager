class Drawing < ApplicationRecord
  belongs_to :design_project
  belongs_to :created_by
end
