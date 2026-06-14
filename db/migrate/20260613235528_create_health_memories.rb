class CreateHealthMemories < ActiveRecord::Migration[7.1]
  def change
    create_table :health_memories do |t|
      t.references :user, null: false, foreign_key: true
      t.references :record, null: false, foreign_key: true
      t.string :category
      t.string :title
      t.text :value
      t.date :source_date
      t.integer :confidence

      t.timestamps
    end
  end
end
