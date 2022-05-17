require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    # 別のユーザーを追加
    @other_user = users(:archer)
  end

  test "should get new" do
    get signup_path
    assert_response :success
  end

  test "should redirect index when not logged in" do
    # users#indexまでのパス
    get users_path

    # ログインURLまでリダイレクトされているか？
    assert_redirected_to login_url
  end

  test "should redirect edit when not logged in" do
    # 個々のユーザー編集ページにget
    get edit_user_path(@user)
    
    # flashメッセージが空ではないか？ -> 存在するということは、getリクエストをしたときにエラーが発生しているということ
    assert_not flash.empty?

    # ログインページに正常にリダイレクトされるか?
    assert_redirected_to login_url
  end

  test "should redirect update when not logged in" do
    # patchリクエストを送信
    patch user_path(@user), 
      params: {
        user: {
          name: @user.name,
          email: @user.email
        }
      }

    # flashメッセージが空ではないか？-> 存在するということは、patchリクエストをしたときにエラーが発生しているということ
    assert_not flash.empty?

    # ログインページに正常にリダイレクトされるか?
    assert_redirected_to login_url
  end

  test "should redirect edit when logged in as wrong user" do
    # 別のユーザーとしてログインしてみる
    log_in_as(@other_user)

    # 本物のユーザー(michael)の編集ページに移動する
    get edit_user_path(@user)
    
    # flashメッセージが空であるか？
    assert flash.empty?

    # ルートパスにリダイレクトされているか？
    assert_redirected_to root_url
  end

  test "should redirect update when logged in as wrong user" do 
    # 別のユーザーでログインする
    log_in_as(@other_user)

    # 別のユーザーがログインしている状態で、本物のユーザー（michael）情報を更新する
    patch user_path(@user), 
      params: {
        user: {
          name: @user.name,
          email: @user.email
        }
      }

    # flashメッセージが空であるか？
    assert flash.empty?

    # ルートパスにリダイレクトされているか？
    assert_redirected_to root_url
  end

  test "should not allow the admin attribute to be edited via the web" do
    # 攻撃者としてログイン
    log_in_as(@other_user)

    # 攻撃者に対して管理者権限が存在しないか？
    assert_not @other_user.admin?

    # 攻撃者が管理者権限の付与をリクエスト
    patch user_path(@other_user), 
      params: {
        user: {
          password: @other_user.password,
          password_confirmation: @other_user.password,
          admin: true
        }
      }
    
    # DBの更新後、攻撃者の管理者権限が存在しないか？
    assert_not @other_user.reload.admin?
  end

  # ログインしていないユーザーがdestoryをリクエストしたとき
  test "should redirect destroy when not logged in" do
    # ブロックで渡されたものを呼び出す前後でUser.countに違いがない -> ログイン自体していないため、User.countが増減するわけがない
    assert_no_difference 'User.count' do
      # user_path(@user)にdeleteリクエスト
      delete user_path(@user)
    end
    
    # ログインページにリダイレクトされるか？
    assert_redirected_to login_url
  end

  # 管理者権限を持たないユーザーがdestroyをリクエストしたとき
  test "should redirect destroy when logged in as a non-admin" do 
    # 管理者権限を持たいないユーザー
    log_in_as(@other_user)

    # ブロックで渡されたものを呼び出す前後でUser.countに違いがない -> 管理者権限を持たないのだから、User.countが増減するわけがない
    assert_no_difference 'User.count' do
      # user_path(@user)にdeleteリクエスト
      delete user_path(@user)
    end

    # ログインページにリダイレクトされるか？
    assert_redirected_to root_url
  end

  # 管理者権限を持つユーザーがdestroyをリクエストしたとき
  

end
