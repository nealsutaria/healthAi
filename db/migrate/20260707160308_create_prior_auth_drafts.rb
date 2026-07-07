class CreatePriorAuthDrafts < ActiveRecord::Migration[7.1]
  def change
    create_table :prior_auth_drafts do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :patient_name
      t.string :condition
      t.string :requested_service
      t.string :insurance_payer
      t.text :prior_treatments
      t.text :clinical_notes
      t.text :tests_or_imaging
      t.text :content
      t.string :status

      t.timestamps
    end
  end
end
