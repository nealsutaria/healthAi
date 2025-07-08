# app/models/record.rb
class Record < ApplicationRecord
  belongs_to :user
  has_one_attached :image

  validates :date, :reason, presence: true
end
