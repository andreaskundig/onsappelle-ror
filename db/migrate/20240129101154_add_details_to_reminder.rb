class AddDetailsToReminder < ActiveRecord::Migration[7.1]
  def change
    add_column :reminders, :description, :string
    add_column :reminders, :sent_at, :datetime
    add_column :reminders, :confirmed_at, :datetime
  end
end
