class CreateTasksTable < ActiveRecord::Migration[7.0]
  def change
    create_table :tasks, id: :uuid do |t|
      t.uuid :task_idx, null: false
      t.string :description, null: false
      t.references :user, type: :uuid, null: true
      t.integer :status, default: 0
      t.timestamp :completed_at, null: true
      t.float :cost
      t.float :reward

      t.timestamps
    end
    add_index :tasks, :task_idx, unique: true
  end
end
