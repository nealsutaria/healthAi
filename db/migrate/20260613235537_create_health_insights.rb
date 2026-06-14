class CreateHealthInsights < ActiveRecord::Migration[7.1]
  def change
    create_table :health_insights do |t|
      t.references :user, null: false, foreign_key: true
      t.references :record, null: false, foreign_key: true
      t.string :title
      t.text :body
      t.string :severity
      t.string :status
      t.string :source

      t.timestamps
    end
  end
end
