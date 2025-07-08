class CreateRecords < ActiveRecord::Migration[7.1]
  def change
    create_table :records do |t|
      t.date :date
      t.string :reason
      t.boolean :prescription
      t.string :prescription_name
      t.boolean :xray_done
      t.boolean :test_done
      t.string :test_type
      t.integer :doctor_rating
      t.text :comments

      t.timestamps
    end
  end
end
