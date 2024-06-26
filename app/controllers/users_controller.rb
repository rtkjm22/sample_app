class UsersController < ApplicationController

  # logged_in_userアクションが発火する前に実行(edit, updateアクションの実行前だけに実行)
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy, :following, :followers]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy

  def index
    # すべてのユーザー情報を取得する -> 有効化していないユーザーは取得しない
    # paginateを使うことでユーザーのページネーションが可能になる
    # 引数のpageパラメーターにはparams[:page]とあるが、これはwill_paginateメソッドにより自動的に生成される
    @users = User.where(activated: true).paginate(page: params[:page])
  end
  
  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
    redirect_to root_url and return unless @user.activated?
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      # model/user.rb -> @userの情報に基づいてメールが送信される
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    # user_paramsはprivateで定義済み
    # 更新の成功可否で分岐
    if @user.update(user_params)  
      # 更新に成功した場合
      flash[:success] = "プロフィールの編集が成功しました。"
      # ユーザー個人のページに移動
      redirect_to @user
    else
      # 更新に失敗した場合
      # 編集ページを再描画
      render 'edit'
    end
  end

  def destroy
    user = User.find(params[:id])
    user.destroy
    flash[:success] = "#{user.name}さんを削除しました。"
    redirect_to  users_url
  end

  def following
    @title = "Following"
    @user  = User.find(params[:id])
    @users = @user.following.paginate(page: params[:page])
    # users/show_follow.html.erbを出力
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user  = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end

  private

    # Strong Parameters
    # admin（管理者権限）の設定を許可しない
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    # 正しいユーザーかどうか確認
    def correct_user
      @user = User.find(params[:id])

      # 現在のユーザーと異なっている場合はルートにリダイレクトするようにする
      # @userは送信されてきたユーザー情報
      # current_userは現在ログインしているユーザーのこと
      redirect_to(root_url) unless current_user?(@user)
    end

    # ログイン中のユーザーがadmin（管理者権限）を持っているかどうか?
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
