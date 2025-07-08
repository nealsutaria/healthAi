# app/models/user.rb
class User < ApplicationRecord
  # Enable Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  has_many :records, dependent: :destroy
  has_many :messages, dependent: :destroy

  # Handles finding or creating a user from Google data
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      # Optional: user.name = auth.info.name
      # Optional: user.avatar_url = auth.info.image
      # If using confirmable:
      # user.skip_confirmation!
    end
  end
end


