class AddAdminToUsers < ActiveRecord::Migration[6.0]
  def change
    # 管理者権限
    add_column :users, :admin, :boolean, default: false   # nilでもfalseになるが、明示的に示したほうが良い
  end
end
