class CreateActivityRegistrations < ActiveRecord::Migration[8.1]
  def change
    create_table :activity_registrations do |t|
      t.bigint :activity_id, null: false
      t.bigint :user_id, null: false
      t.integer :status, null: false, default: 0
      t.integer :payment_method
      t.string :collector
      t.datetime :paid_at
      t.string :cancel_reason
      t.datetime :cancelled_at
      t.decimal :refund_amount, precision: 10, scale: 2
      t.datetime :refunded_at

      t.timestamps
    end

    add_foreign_key :activity_registrations, :activities
    add_foreign_key :activity_registrations, :users
    add_index :activity_registrations, [ :activity_id, :user_id ], unique: true
  end
end
