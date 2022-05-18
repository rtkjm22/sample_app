require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  def setup
    #deliveriesは変数
    # 配信されたメッセージに関する情報
    # 他のテストのときにメールが配信されるとエラーが発生してしまうため、clear
    ActionMailer::Base.deliveries.clear
  end
  
  # 無効なサインアップ情報のとき
  test "invalid signup information" do
    # サインアップページにgetリクエスト
    get signup_path

    # ユーザー総数に変更がない => サインアップに失敗
    assert_no_difference 'User.count' do 
      # 無効なユーザー情報でサインアップリクエスト
      post users_path, 
        params: { 
          user: {  
            name: "",
            email: "user@invaolid",
            password: "foo",
            password_confirmation: "bar"
          }
        }
    end

    # newビューが正しく描画されているか？
    assert_template 'users/new'
    assert_select 'div#error_explanation'
    assert_select 'div.field_with_errors'
  end

  # 有効なサインアップ情報のとき
  test "valid signup information with account activation" do
    # サインアップページにgetリクエスト
    get signup_path

    # ユーザー総数が1増加したとき
    assert_difference 'User.count', 1 do
      post users_path, 
        params: { 
          user: { 
            name:  "Example User",
            email: "user@example.com",
            password:              "password",
            password_confirmation: "password" 
          } 
        }
    end

    # 配信されたメッセージがきっかり1つであるかどうか？
    assert_equal 1, ActionMailer::Base.deliveries.size

    # assignsはUsersコントローラー内の@userにアクセスできる
    user = assigns(:user)

    # ユーザーが有効化されていないか?
    assert_not user.activated?

    # 有効化していない状態でログインしてみる
    log_in_as(user)

    # テストユーザーがログインしていないか？ => 出来ていないほうが良い
    assert_not is_logged_in?

    # トークンは正しいがメールアドレスが無効な場合
    get edit_account_activation_path(user.activation_token, email: 'wrong')

    # テストユーザーがログインしていないか？ => 出来ていないほうが良い
    assert_not is_logged_in?

    # 有効化トークンとメールアドレスが正しい場合
    get edit_account_activation_path(user.activation_token, email: user.email)
    
    # DBを更新したあとにユーザーが有効化されているか？
    assert user.reload.activated?

    # 実際にリダイレクトされているか?
    follow_redirect!

    # プロフィール画面が正常に描画されているか?
    assert_template 'users/show'

    # テストユーザーがログインしているか？ => 出来ていたほうが良い
    assert is_logged_in?
  end

end
