class DropBalanceUpdatedAtColumnInUsers < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :balance_update_time
  end
end
