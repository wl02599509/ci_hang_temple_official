class CreateActivities < ActiveRecord::Migration[8.1]
  def change
    create_table :activities do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.text :notes
      t.date :event_date, null: false
      t.date :registration_start_date, null: false
      t.date :registration_end_date, null: false
      t.decimal :fee, precision: 10, scale: 2, null: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
