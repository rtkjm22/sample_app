require 'test_helper'

class UsersProfileTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  def setup
    @user = users(:michael)
  end

  test "profile display" do
    get user_path(@user)
    assert_template 'users/show'

    # full_titleはヘルパー関数 -> "name | Ruby on Rails Tutorial Sample App"
    assert_select 'title', full_title(@user.name)
    assert_select 'h1', text: @user.name
    assert_select 'h1>img.gravatar'
    assert_match @user.microposts.count.to_s, response.body
    assert_select 'div.pagination'

    # マイクロポストのcontentが含まれているか? -> 存在しない場合は無視
    @user.microposts.paginate(page: 1).each do |post|
      assert_match post.content, response.body
    end
    assert_select 'div.pagination', count: 1


    # @user.micropost.count(30) do 
    #   assert_select 'div.pagination', count: 1
    # end


  end
end
