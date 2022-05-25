class ApplicationController < ActionController::Base
  # どのページからでもログイン関連のメソッドを呼べるようにする
  include SessionsHelper

  private

    # ユーザーのログインを確認する
    # ログイン済みユーザーかどうか確認
    def logged_in_user
      # current_userがnilであるかないか？ -> nilだった場合はログインしていない状態
      unless logged_in?
        # getリクエストを受け取ったときに、session変数の:forwading_urlキーにリクエストが送られたURLを格納する
        store_location
        
        flash[:danger] = "ログインしてください！"
        redirect_to  login_url
      end
    end
end
