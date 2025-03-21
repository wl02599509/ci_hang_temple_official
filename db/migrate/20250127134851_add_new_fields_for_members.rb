# frozen_string_literal: true

class AddNewFieldsForMembers < ActiveRecord::Migration[8.0]
  def change
    change_table :members, bulk: true do |t|
      t.string :name, null: false, default: ''
      t.string :home_phone_number, limit: 10
      t.string :mobile_phone_number, limit: 10
      t.string :address
      t.date :birthday
      t.string :email
    end
  end
end
