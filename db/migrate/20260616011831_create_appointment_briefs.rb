class CreateAppointmentBriefs < ActiveRecord::Migration[7.1]
  def change
    create_table :appointment_briefs do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.text :content

      t.timestamps
    end
  end
end
