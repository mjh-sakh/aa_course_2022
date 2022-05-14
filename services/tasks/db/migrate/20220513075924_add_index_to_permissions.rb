class AddIndexToPermissions < ActiveRecord::Migration[7.0]
  def change
    add_index :permissions, :name, unique: true
  end
end
