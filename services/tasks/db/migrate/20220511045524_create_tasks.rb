class CreateTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :tasks, id: :uuid do |t|
      t.string :description, null: false
      t.references :user, type: :uuid, null: true
      t.integer :status, default: 0
      t.timestamp :completed_at, null: true

      t.timestamps
    end
  end
end
