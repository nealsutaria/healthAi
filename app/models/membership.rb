class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :organization

  ROLES = %w[owner provider billing_staff staff].freeze

  validates :role, presence: true, inclusion: { in: ROLES }
  validates :user_id, uniqueness: { scope: :organization_id }

  def owner?
    role == "owner"
  end

  def provider?
    role == "provider"
  end

  def billing_staff?
    role == "billing_staff"
  end

  def staff?
    role == "staff"
  end

  def can_manage_members?
    owner?
  end

  def can_manage_prior_auth_drafts?
    owner? || provider? || billing_staff?
  end

  def can_view_prior_auth_drafts?
    owner? || provider? || billing_staff? || staff?
  end
end
