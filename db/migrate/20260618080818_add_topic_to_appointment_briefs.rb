class AddTopicToAppointmentBriefs < ActiveRecord::Migration[7.1]
  def change
    add_column :appointment_briefs, :topic, :string
  end
end
