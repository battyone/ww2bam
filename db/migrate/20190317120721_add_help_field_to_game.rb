class AddHelpFieldToGame < ActiveRecord::Migration
  def change
    add_column :games, :fifty_fifty_used, :boolean, default: false, null: false
    add_column :games, :audience_help_used, :boolean, default: false, null: false
    add_column :games, :friends_call_used, :boolean, default: false, null: false
  end
end
