require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest
  
  def setup
    # deliveriesは変数
    # 配信されたメッセージに関する情報
    # 他のテストのときにメールが配信されるとエラーが発生してしまうため、clear
    ActionMailer::Base.deliveries.clear
    @user = users(:michael)
  end

  test "password resets" do
    # newページにリクエスト
    get new_password_reset_path

    # newページが正常に描画されているか？
    assert_template 'password_resets/new'

    # inputタグのname属性にemail情報が入っているか
    assert_select 'input[name=?]', 'password_reset[email]'

    # メールアドレスが無効 ######################################
    post password_resets_path, 
      params: {
        password_reset: {
          email: ""
        }
      }

    # メールアドレスが無効なため、flashメッセージが無くてはならない
    assert_not flash.empty? 

    # newページが正常に描画されているか？
    assert_template 'password_resets/new'

    # メールアドレスが有効 #######################################
    post password_resets_path, 
      params: {
        password_reset: {
          email: @user.email
        }
      }

    # DB上のreset_digestがリロードされた後に変更されているか?
    assert_not_equal @user.reset_digest, @user.reload.reset_digest

    # 送信されるメールは1つであるか?
    assert_equal 1, ActionMailer::Base.deliveries.size

    # flashメッセージが存在することを確認
    assert_not flash.empty?

    # ルートページにリダイレクトされているか?
    assert_redirected_to root_url

    # パスワード再設定用フォームのテスト ##############################
    # @userを参照
    user = assigns(:user)

    # メールアドレスが無効 ###############################
    get edit_password_reset_path(user.reset_token, email: "")

    # メールアドレスが無効のためルートページに移動
    assert_redirected_to root_url

    # 無効なユーザー ###################################
    # michaelの有効化を解除
    user.toggle!(:activated)

    # 正しいメールアドレスで確認
    get edit_password_reset_path(user.reset_token, email: user.email)

    # 無効なユーザーのため、ルートリンクにリダイレクト
    assert_redirected_to root_url

    # ユーザーを有効にする
    user.toggle!(:activated)

    # メールアドレスもトークンも有効 #######################
    get edit_password_reset_path(user.reset_token, email: user.email)
    
    # パスワード再設定用フォームが正常に描画されているか確認
    assert_template 'password_resets/edit'

    # パスワード再設定用フォームにて、
    # 正しい名前、typeがhidden、メールアドレスがあるかどうかを確認
    assert_select "input[name=email][type=hidden][value=?]", user.email

    # 無効なパスワードとパスワード確認 #############################
    # パスワードが一致していない状態でpatchリクエスト
    patch password_reset_path(user.reset_token),
      params: {
        email: user.email,
        user: {
          password: "foobaz",
          password_confirmation: "barquux"
        }
      }
    
    # エラーメッセージが表示されているか?
    assert_select 'div#error_explanation'

    # パスワードが空 ############################################

    patch password_reset_path(user.reset_token),
      params: {
        email: user.email,
        user: {
          password: "",
          password_confirmation: ""
        }
      }

    # エラーメッセージが表示されているか?
    assert_select 'div#error_explanation'

    # 有効なパスワードとパスワード確認 #############################
    patch password_reset_path(user.reset_token),
      params: {
        email: user.email,
        user: {
          password: "foobaz",
          password_confirmation: "foobaz"
        }
      }

    # ログイン処理は正常にされたか?
    assert is_logged_in?

    # "Password has been reset"メッセージが表示されているか?
    assert_not flash.empty?

    # プロフィールページに移動しているか?
    assert_redirected_to user 

    # パスワード変更後、ログイン処理が完了した時点でreset_digestはnilになっているか?
    assert_nil user.reload.reset_digest
  end

  test "expired token" do
    # forgot passwordのページにリクエスト
    get new_password_reset_path

    # 有効なメールアドレスでpostリクエスト
    post password_resets_path, 
      params: {
        password_reset: {
          email: @user.email
        }
      }
    
    # Userクラスのインスタンスを取得
    @user = assigns(:user)

    # 3時間後を期限として更新しておく
    @user.update_attribute(:reset_sent_at, 3.hours.ago)

    patch password_reset_path(@user.reset_token),
      params: {
        email: @user.email,
        user: {
          password: "foobar",
          password_confirmation: "foobar"
        }
      }
    
    assert_response :redirect

    # 実際にリダイレクトする
    follow_redirect!

    # リダイレクト先にexpiredという文字列が存在するか正規表現でチェックする
    assert_match /expired/i, response.body
  end

end
