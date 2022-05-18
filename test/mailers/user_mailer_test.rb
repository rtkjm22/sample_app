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
  # test "password_reset" do
  #   mail = UserMailer.password_reset
  #   assert_equal "Password reset", mail.subject
  #   assert_equal ["to@example.org"], mail.to
  #   assert_equal ["from@example.com"], mail.from
  #   assert_match "Hi", mail.body.encoded
  # end

end
