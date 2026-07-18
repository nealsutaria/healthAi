class ClinicInvitation < ApplicationRecord
  belongs_to :organization
  belongs_to :invited_by, class_name: "User"

  before_validation :normalize_email
  before_validation :generate_token, on: :create

  validates :email, presence: true
  validates :role, presence: true
  validates :token, presence: true, uniqueness: true

  def accepted?
    accepted_at.present?
  end

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end

  def generate_token
    self.token ||= SecureRandom.urlsafe_base64(32)
  end
end
