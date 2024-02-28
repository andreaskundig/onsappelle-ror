class AddLocaleToReminder < ActiveRecord::Migration[7.1]
  def change
    add_column :reminders, :locale, :string
  end
end
