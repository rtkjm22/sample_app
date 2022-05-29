require 'test_helper'

class FollowingTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @other = users(:archer)
    log_in_as(@user)
  end

  # 自分がフォローしている一覧画面
  test "following page" do
    get following_user_path(@user)

    # この時点で空になっている場合は下のassert_select自体が実行される前にブロックされるため、正しくテストできるようになる
    assert_not @user.following.empty?
    assert_match @user.following.count.to_s, response.body
    @user.following.each do |user|
      assert_select "a[href=?]", user_path(user)
    end
  end

  # 自分がフォローされている一覧画面
  test "followers page" do
    get followers_user_path(@user)
    assert_not @user.followers.empty?
    assert_match @user.followers.count.to_s, response.body
    @user.followers.each do |user|
      assert_select "a[href=?]", user_path(user)
    end
  end

  # ページ遷移ありのフォロー処理の流れ
  test "should follow a user the standard way" do
    # フォローしている人数が+1になっているか?
    assert_difference '@user.following.count', 1 do
      post relationships_path, params: { followed_id: @other.id }
    end
  end

  # Ajax使用時のフォロー処理の流れ
  test "should follow a user with Ajax" do
    assert_difference '@user.following.count', 1 do
      # xhr -> Ajaxでリクエストを発行
      post relationships_path, xhr: true, params: { followed_id: @other.id }
    end
  end

  # 上記と同様
  test "should unfollow a user the standard way" do
    @user.follow(@other)
    relationship = @user.active_relationships.find_by(followed_id: @other.id)
    assert_difference '@user.following.count', -1 do
      delete relationship_path(relationship)
    end
  end

  # 上記と同様(Ajaxあり)
  test "should unfollow a user with Ajax" do
    @user.follow(@other)
    relationship = @user.active_relationships.find_by(followed_id: @other.id)
    assert_difference '@user.following.count', -1 do
      delete relationship_path(relationship), xhr: true
    end
  end

  # ホームページの1ページ目のフィードに対して
  test "feed on Home page" do
    get root_path
    @user.feed.paginate(page: 1).each do |micropost|
      # railsで特殊文字(<,>,\n等)を扱うためにエスケープをしておきたい -> escapeHTMLをする
      assert_match CGI.escapeHTML(micropost.content), response.body
    end
  end
end
