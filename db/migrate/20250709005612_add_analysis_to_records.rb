class AddAnalysisToRecords < ActiveRecord::Migration[7.1]
  def change
    add_column :records, :analysis, :text
  end
end
