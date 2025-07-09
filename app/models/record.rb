# app/models/record.rb
class Record < ApplicationRecord
  belongs_to :user
  has_one_attached :image

  validates :date, :reason, presence: true
  before_save :clear_analysis_if_image_changed

  private

  def clear_analysis_if_image_changed
    if image_changed?
      self.analysis = nil
    end
  end

  def image_changed?
    return true if new_record? && image.attached?

    if image.attached?
      previous_blob_id = image_attachment&.blob_id_before_last_save
      current_blob_id = image.blob.id
      previous_blob_id.present? && previous_blob_id != current_blob_id
    else
      false
    end
  end
end
