module SessionsHelper
  # 渡されたユーザーでログインする
  def log_in (user)
    session[:user_id] = user.id
  end

  # ユーザーのセッションを永続的にする
  def remember(user) 
    # model/user.rbより
    user.remember
    # 署名付きCookiesを使う(permanent = 永続化する)
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # 現在ログイン中のユーザーを返す(いる場合)
  def current_user
    # if session[:user_id]
    #   @current_user ||= User.find_by(id: session[:user_id])
    # elseif cookies.signed[:user_id]
    #   user = User.find_by(id: cookies.signed[:user_id])
    #   if user && user.authenticated?(cookies[:remember_token]) 
    #     log_in user
    #     @current_user = user
    #   end
    # end

    # 記憶トークンcookieに対応するユーザーを返す
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  # ユーザーがログインしていればtrue、その他ならfalse
  def logged_in?
    !current_user.nil?
  end

  # 永続的セッションを破棄する
  def forget(user) 
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # 現在のユーザーをログアウトする
  def log_out
    # remember_digestをnilにする -> model/user.rb
    forget(current_user)

    session.delete(:user_id)
    @current_user = nil
  end

end
