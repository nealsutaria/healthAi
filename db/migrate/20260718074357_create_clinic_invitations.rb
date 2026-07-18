class CreateClinicInvitations < ActiveRecord::Migration[7.1]
  def change
    create_table :clinic_invitations do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :invited_by, null: false, foreign_key: { to_table: :users }
      t.string :email
      t.string :role
      t.string :token
      t.datetime :accepted_at

      t.timestamps
    end
  end
end
