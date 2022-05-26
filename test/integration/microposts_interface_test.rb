require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest
  
  def setup
    # ユーザーはマイケルとする
    @user = users(:michael)
  end

  test "micropost interface" do
    log_in_as(@user)
    get root_path

    # ページネーションがあるかどうか
    assert_select 'div.pagination'

    # 画像が表示されたかどうか?
    assert_select 'input[type=file]'

    # 無効なマイクロソフトを作成、送信
    assert_no_difference 'Micropost.count' do
      post microposts_path, 
        params: {
          micropost: {
            content: ""
          }
        }
    end

    # エラー文があるか
    assert_select 'div#error_explanation'

    # 正しいページリンクがあるかどうか?
    assert_select 'a[href=?]', '/?page=2'

    # 有効な送信
    content = "this micropost really ties the room together"
    image   = fixture_file_upload('test/fixtures/kitten.jpg', 'image/jpeg')

    # マイクロポストが増えているか?
    assert_difference 'Micropost.count', 1 do
      post microposts_path, 
        params: {
          micropost: {
            content: content,
            image: image
          }
        }
    end

    assert assigns(:micropost).image.attached?
    assert_redirected_to root_path

    # 実際にリダイレクトされているか?
    follow_redirect!

    # 有効な送信をしたときの値がレンダリングされたHTMLに含まれているか?
    assert_match content, response.body

    # 投稿を削除
    assert_select 'a', text: 'delete'

    # マイケルのページネーション一番最初の投稿
    first_micropost = @user.microposts.paginate(page: 1).first

    # 投稿が一つ減っているか?
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end

    # 違う人がプロフィールにアクセス(削除リンクが内容にしたい)
    get user_path(users(:archer))

    # deleteボタンが存在しない -> archerが削除出来てしまうため
    assert_select 'a', text: 'delete', count: 0
  end

  # 投稿の合計投稿数が正しく表示されているか？
  test "micropost sidebar count" do
    log_in_as(@user)
    get root_path
    micropost_num = @user.microposts.count

    # 複数形なことに注目
    assert_match  "#{micropost_num} microposts", response.body
    other_user = users(:malory)
    log_in_as(other_user)
    get root_path
    assert_match "0 microposts", response.body

    # 擬似的に１つ目の投稿を作成
    other_user.microposts.create!(content: "A micropost")
    get root_path

    # 一つの投稿が単数形で表示されている
    assert_match "1 micropost", response.body
  end

end
