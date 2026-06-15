class CreateDoctorQuestions < ActiveRecord::Migration[7.1]
  def change
    create_table :doctor_questions do |t|
      t.references :user, null: false, foreign_key: true
      t.text :question
      t.string :source
      t.string :status

      t.timestamps
    end
  end
end
