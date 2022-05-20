require 'test_helper'

class MicropostTest < ActiveSupport::TestCase
  
  def setup
    @user = users(:michael)
    # @micropost = Micropost.new(content: "Lorem ipsum", user_id: @user.id)
    @micropost = @user.microposts.build(content: "Lorem ipsum")
  end

  test "should be valid" do
    # 作成されたマイクロポストが有効であるか
    assert @micropost .valid?
  end

  # user_idが存在しているか?
  test "user id should be present" do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end

  # contentが含まれているか?
  test "content should be present" do
    @micropost.content = "   "
    assert_not @micropost.valid?
  end

  # contentは140文字以内か
  test "content should be at most 140 characters" do
    @micropost.content = "a" * 141
    assert_not @micropost.valid?
  end

  # DB上の最初のマイクロソフトがfixture内のマイクロポストと同じであるか検証
  test "order should be most recent first" do
    # :most_recentはfixture内の一番新しいポスト
    assert_equal microposts(:most_recent), Micropost.first
  end
end
