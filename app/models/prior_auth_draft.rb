class PriorAuthDraft < ApplicationRecord
  belongs_to :organization
  belongs_to :user

  validates :patient_name, presence: true
  validates :condition, presence: true
  validates :requested_service, presence: true
  validates :insurance_payer, presence: true
  validates :status, presence: true
end
