class CreateTransactionLogRecord < ActiveRecord::Migration[7.0]
  def change
    create_table :transaction_log_records, id: :uuid do |t|
      t.references :user, type: :uuid, null: false
      t.timestamp :event_time, null: false
      t.timestamp :record_time, null: false
      t.float :amount, null: false
      t.integer :record_type, null: false
      t.uuid :reference_id, null: true # null for payments, tasks for bills and rewards
      t.string :note

      t.timestamps
    end
    add_index :transaction_log_records, :record_time, using: 'BRIN'
    add_index :transaction_log_records, :record_type
  end
end
