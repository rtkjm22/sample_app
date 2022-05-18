require 'test_helper'

class UsersActivationTest < ActionDispatch::IntegrationTest
  
  # 有効化されているユーザー(@activated_user)
  # 有効化されていないユーザー(@non_activated_user)
  def setup
    @user = users(:hongo)
    @non_activated_user = users(:shocker)
  end

  test "index should lists only activated user when activated user logged in" do
    # 有効なユーザーでログイン
    log_in_as(@user)

    # 一覧ページにgetリクエスト
    get users_path

    # 一覧ページが描画されているか？
    assert_template 'users/index'

    # 一覧ページに@userの表示があるか?
    assert_select "a[href=?]", user_path(@user)

    # 一覧ページに有効化されていないユーザーが表示されていないか?
    assert_select "a[href=?]", user_path(@non_activated_user), count: 0
  end

  test "show should lists only activated user when activated user logged in" do
    # 有効なユーザーでログイン
    log_in_as(@user)

    # 有効なユーザーページにgetリクエスト
    get user_path(@user)

    # プロフィールページが描画されているか？
    assert_template 'users/show'

    # 有効なユーザーの名前が描画されているか?
    assert_select "h1", text: @user.name

    # 無効なユーザープロフィール画面にリクエスト
    get user_path(@non_activated_user)

    # ルートまでリダイレクトされているか?
    assert_redirected_to root_url
  end

end
