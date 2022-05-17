require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test "unsuccessful edit" do
    # 事前にログインしておく(editやupdateアクションをテストする前にログインしておく必要があるため)
    log_in_as(@user)

    # 編集ページヘアクセス
    get edit_user_path(@user)

    # editビューが描画されているか？
    assert_template 'users/edit'

    # 無効な情報を送信
    patch user_path(@user), 
      params: {
        user: {
          name: "",
          email: "foo@invalid",
          password: "foo",
          password_confirmation: "bar"
        }
      }

    # editビューが再描画されるか？
    assert_template 'users/edit'

    # エラー文の中に"The form contains 4 errors."が含まれているか？
    assert_select "div.alert", "The form contains 4 errors."
  end

  # test "successfull edit" do 

  #   # 事前にログインしておく(editやupdateアクションをテストする前にログインしておく必要があるため)
  #   log_in_as(@user)

  #   # 編集ページへアクセス
  #   get edit_user_path(@user)

  #   # editビューが描画されているか？
  #   assert_template 'users/edit'

  #   # 有効な情報を送信する
  #   name = "Foo Bar"
  #   email = "foo@bar.com"
  #   patch user_path(@user),
  #     params: {
  #       user: {
  #         name: name,
  #         email: email,
  #         password: "",
  #         password_confirmation: ""
  #       }
  #     }

  #   # フラッシュメッセージが含まれていないか？
  #   assert_not flash.empty?

  #   # リダイレクト先が正しいか?
  #   assert_redirected_to @user

  #   # データベースから最新の情報を読み込み直す
  #   @user.reload

  #   # 上で定義している値とデータベースの値が等しいか？(name: 上で定義しているname, @user.name: データベース上のname)
  #   assert_equal name, @user.name
  #   assert_equal email, @user.email

  # end

  test "successful edit with friendly forwading" do 
    # 編集ページにgetしているか？
    get edit_user_path(@user)

    # ログイン処理
    log_in_as(@user)

    # ユーザー編集ページにリダイレクトされているか？
    assert_redirected_to edit_user_url(@user)

    name = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user),
      params: {
        user: {
          name: name,
          email: email,
          password: "",
          password_confirmation: ""
        }
      }
    
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name, @user.name
    assert_equal email, @user.email

  end

end
