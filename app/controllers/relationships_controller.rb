class RelationshipsController < ApplicationController

  before_action :logged_in_user

  def create
    # フォローされるユーザーのIDを取得
    @user = User.find(params[:followed_id])

    # 悪意のあるユーザーがcurl等でアクセス
    # -> current_userがnilになり、エラーが発生
    # -> テストでは一応ログインページに移動することを明示的にテストした
    current_user.follow(@user)

    # ビューで変数を使うためuser -> @userに変更 ??
    # Ajaxに対応 -> format.js
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end

  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow(@user)

    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end

end
