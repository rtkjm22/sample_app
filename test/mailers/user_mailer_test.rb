require 'test_helper'

class UserMailerTest < ActionMailer::TestCase

  test "account_activation" do
    # userにテストユーザーmichaelを代入
    user = users(:michael)
    user.activation_token = User.new_token
    mail = UserMailer.account_activation(user)

    # "Account activation"とmail.subjectが等しい
    assert_equal "Account activation", mail.subject

    # [user.email]と mail.toが等しい
    assert_equal [user.email], mail.to

    # ["noreply@example.com"]と mail.fromが等しい
    assert_equal ["noreply@example.com"], mail.from

    # user.nameが本文に含まれている
    assert_match user.name,               mail.text_part.body.encoded
    assert_match user.name,               mail.html_part.body.encoded

    # user.activation_tokenが本文に含まれている
    assert_match user.activation_token,   mail.text_part.body.encoded
    assert_match user.activation_token,   mail.html_part.body.encoded

    # 特殊文字をエスケープしたuser.mailが本文に含まれている
    assert_match CGI.escape(user.email),  mail.text_part.body.encoded
    assert_match CGI.escape(user.email),  mail.html_part.body.encoded
  end

  test "password_reset" do
    # 管理者ユーザー
    user = users(:michael)

    # リセットトークンに新しく作成したトークンを作成
    user.reset_token = User.new_token

    # メールを送信
    mail = UserMailer.password_reset(user)

    # メールタイトルが正しいものか?
    assert_equal "Password reset", mail.subject

    # 送信先のメールアドレスがユーザーのものか?
    assert_equal [user.email], mail.to

    # 送信元のメールアドレスは正しいものか?
    assert_equal ["noreply@example.com"], mail.from

    # メール内のハッシュ化済みリセットトークンは正しいものか?
    assert_match user.reset_token, mail.text_part.body.encoded
    assert_match user.reset_token, mail.html_part.body.encoded

    # メール内のハッシュ済みメールアドレスは正しいものか?
    assert_match CGI.escape(user.email), mail.text_part.body.encoded
    assert_match CGI.escape(user.email), mail.html_part.body.encoded
  end

end
