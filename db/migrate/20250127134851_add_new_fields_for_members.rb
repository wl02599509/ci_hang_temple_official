class AddNewFieldsForMembers < ActiveRecord::Migration[8.0]
  def change
    add_column :members, :name, :string, null: false, default: ''
    add_column :members, :home_phone_number, :string, limit: 10
    add_column :members, :mobile_phone_number, :string, limit: 10
    add_column :members, :address, :string
    add_column :members, :birthday, :date
    add_column :members, :email, :string
  end
end
