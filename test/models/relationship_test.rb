require 'test_helper'

class RelationshipTest < ActiveSupport::TestCase

  # フォローしている人 -> michael
  # フォローされている人 -> archer
  def setup
    @relationship = Relationship.new( follower_id: users(:michael).id,
                                      followed_id: users(:archer).id)
  end

  test "should be valid" do
    # フォローの関係性があるか
    assert @relationship.valid?
  end

  test "should require a follower_id" do
    # フォローしている人のIDが存在しない
    @relationship.follower_id = nil
    assert_not @relationship.valid?
  end

  test "should require a followed_id" do
    # フォローされている人のIDが存在しない
    @relationship.followed_id = nil
    assert_not @relationship.valid?
  end

  
end
