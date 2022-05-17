require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:michael)
    @non_admin = users(:archer)
  end

  # # 一覧ページにページネーションが含まれているか? 
  # test "index including pagination" do
  #   # michaelでログインする
  #   log_in_as(@admin)

  #   # 一覧ページにgetリクエストをする
  #   get users_path

  #   # 一覧ページが描画されているか？
  #   assert_template 'users/index'

  #   # paginationクラスのdivタグが存在するか?
  #   assert_select 'div.pagination', count: 2

  #   # 最初のページにユーザーが存在するのか確認
  #   User.paginate(page: 1).each do | user |
  #     assert_select 'a[href=?]', user_path(user), text: user.name
  #   end

  # end

  # 一覧ページに管理者権限を持つものがログインし、ページネーションとdeleteリンクが含まれているか? 
  test "index as admin including pagination and delete links" do
    # 管理者としてログイン
    log_in_as(@admin)

    # 一覧ページにgetリクエスト
    get users_path

    # 一覧ページが描画されているか？
    assert_template 'users/index'

    # divタグpaginationクラスが含まれているか？
    assert_select 'div.pagination'

    # 1ページ目のユーザー情報
    first_page_of_users = User.paginate(page: 1)

    first_page_of_users.each do |user|
      # <a href="/users/33">user.name</a>の形式かどうか?
      assert_select 'a[href=?]', user_path(user), user.name

      # 管理者にはdeleteリンクは含まれていない？
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end

    # ユーザーを一人削除した後に、User.countは１減っているかどうか？
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end

  # 管理者権限を持たないユーザーが一覧ページにアクセスしたとき
  test "index as non-admin" do
    # 管理者権限を持たないユーザーでログイン
    log_in_as(@non_admin)

    # 一覧ページにgetリクエスト
    get users_path

    # deleteリンク（削除ボタン）が一つもない
    assert_select 'a', text: 'delete', count: 0
  end
end
