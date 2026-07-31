class LifecycleHistory < ApplicationRecord
  belongs_to :product
  belongs_to :changed_by, class_name: 'User', optional: true

  validates :to_state, presence: true

  def from_state_label
    Product.lifecycle_states.key(from_state) || from_state if from_state.present?
  end

  def to_state_label
    Product.lifecycle_states.key(to_state) || to_state
  end
end
