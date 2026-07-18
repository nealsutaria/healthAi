class Organization < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :prior_auth_drafts, dependent: :destroy
  has_many :clinic_invitations, dependent: :destroy

  validates :name, presence: true
end
