class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    # ↓ ユーザーがデータベース上にあり、かつ認証に成功した場合にのみ
    if user && user.authenticate(params[:session][:password])  
      # ユーザーログイン後にユーザー情報のページにリダイレクトする
      log_in user

      # remember_meチェックボックスがチェックされている(1)のとき、cookies情報を記憶する
      params[:session][:remember_me] == '1' ? remember(user) : forget(user)
      
      # リクエストされていたURLにリダイレクトする（getのみ）
      # 今回のdefaultページ->user->ユーザーのプロフィール画面
      redirect_back_or user
    else
      # エラーメッセージを作成する
      flash.now[:danger] = 'メールアドレスとパスワードのどちらかが一致しません。'
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end


end
