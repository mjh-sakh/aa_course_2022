class CreateUsersRolesPermissions < ActiveRecord::Migration[7.0]
  def change
    create_table :users, id: :uuid do |t|
      t.uuid :user_idx
      t.string :name
      t.integer :status, default: 0

      t.timestamps
    end
    add_index :users, :user_idx, unique: true

    create_table :roles, id: :uuid do |t|
      t.string :name

      t.timestamps
    end
    add_index :roles, :name, unique: true

    create_table :permissions, id: :uuid do |t|
      t.string :name

      t.timestamps
    end

    create_table :roles_users, id: false do |t|
      t.uuid :role_id, null: false, index: true
      t.uuid :user_id, null: false, index: true
    end

    create_table :permissions_roles, id: false do |t|
      t.uuid :permission_id, null: false, index: true
      t.uuid :role_id, null: false, index: true
    end
  end
end
