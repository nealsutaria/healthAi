class AddUserToRecords < ActiveRecord::Migration[7.1]
  def change
    add_reference :records, :user, foreign_key: true
  end
end
