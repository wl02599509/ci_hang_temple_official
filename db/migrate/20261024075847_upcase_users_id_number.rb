# Devise 的 case_insensitive_keys 曾將 id_number 轉為小寫儲存，統一轉回大寫。
class UpcaseUsersIdNumber < ActiveRecord::Migration[8.1]
  def up
    execute "UPDATE users SET id_number = UPPER(id_number) WHERE id_number <> UPPER(id_number)"
  end

  def down
    # 資料修正，不需還原
  end
end
