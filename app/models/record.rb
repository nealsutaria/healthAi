# app/models/record.rb
class Record < ApplicationRecord
  belongs_to :user
  has_one_attached :image

  validates :date, :reason, presence: true
  before_save :clear_analysis_if_image_replaced

  private

  def clear_analysis_if_image_replaced
    # Clear AI analysis if image was changed (via Active Storage attachment)
    if image.attached? && image_attachment_id_changed?
      self.analysis = nil
    end
  end
end
