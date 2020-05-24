class Plan < ApplicationRecord
  belongs_to :store
  has_many :plan_images, dependent: :destroy
end
