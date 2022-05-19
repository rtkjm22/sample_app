class PasswordResetsController < ApplicationController

  before_action :get_user,   only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]

  # forgot passwordページ
  def new
  end

  # newページからの情報をもとにユーザーにパスワード再設定用メールを送信
  def create
    # パラメーター(メールアドレス)によってユーザーを検索、取得
    @user = User.find_by(email: params[:password_reset][:email].downcase)

    if @user 
      # modelより参照
      # リセット情報を更新する
      @user.create_reset_digest

      # パスワード再設定用のメールを送信
      @user.send_password_reset_email
      flash[:info] = "Email sent with password reset instructions"
      redirect_to root_url
    else 
      flash.now[:danger] = "Email address not found"
      render 'new'
    end
  end

  # パスワード再設定用メールのリンクをもとにパスワード再設定用フォームを描画
  def edit
  end

  # 実際にパスワードを更新
  def update

    # 新しいパスワードが空文字列になっていないか（ユーザー情報の編集ではOKだった）
    if params[:user][:password].empty?
      # 故意にエラーを発生させる
      @user.errors.add(:password, :blank)
      # パスワード編集画面を再描画
      render 'edit'

    # 新しいパスワードが正しければ、更新する
    elsif @user.update(user_params)
      log_in @user

      # パスワードを更新してから２時間以内は、再度設定フォームを表示してパスワードを変更することが可能になる 
      # -> 悪意のユーザーがパスワードを変更&ログイン出来てしまう
      # DB内のreset_digestをnilにしておけば、再度設定フォームからパスワード変更のリクエストを投げても通らない
      @user.update_attribute(:reset_digest, nil)

      flash[:success] = "Password has been reset."
      redirect_to @user
    else
      # 無効なパスワードであれば失敗させる（失敗した理由も表示する）
      # パスワード編集画面を再描画
      render 'edit'
    end
  end

  private

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    # beforeフィルター

    # ユーザー情報を取得
    def get_user
      @user = User.find_by(email: params[:email])
    end

    # 正しいユーザーかどうか確認
    def valid_user
      unless (@user && @user.activated? && @user.authenticated?(:reset, params[:id]))
        redirect_to root_url
      end
    end

    # パスワードの再設定期限が切れていないかどうか?
    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = "Password reset has expired."
        redirect_to new_password_reset_url
      end
    end
end
