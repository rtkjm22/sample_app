require 'test_helper'

class MicropostsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @micropost = microposts(:orange)
  end

  # ログイン済みでないときはcreateにログインしている
  test "should redirect create when not logged in" do
    # マイクロポストの数に変更がない
    assert_no_difference 'Micropost.count' do
      post microposts_path,
        params: {
          micropost: {
            content: "lorem IpsUm"
          }
        }
    end
    # ログイン画面に遷移
    assert_redirected_to login_url
  end

  test "should redirect destroy when not logged in" do
    assert_no_difference 'Micropost.count' do
      delete micropost_path(@micropost)
    end
    assert_redirected_to login_url
  end

  # 自分以外のユーザーのマイクロポストは削除をしようとすると、適切にリダイレクトされる
  test "should redirect destroy for wrong micropost" do
    log_in_as(users(:michael))

    # 違うユーザーのマイクロポスト
    micropost = microposts(:ants)

    # ポストの総数に違いがない場合は
    # Micropost => model
    assert_no_difference 'Micropost.count' do
      # 一旦deleteリクエスト
      delete micropost_path(micropost)
    end

    # ユーザーが異なるため、ルートパスにリダイレクトされているか?
    assert_redirected_to root_url
  end
end
