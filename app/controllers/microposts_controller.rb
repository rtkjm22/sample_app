class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :correct_user,   only: :destroy

  def create
    @micropost = current_user.microposts.build(micropost_params)

    if @micropost.save  
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else 
      # ログインしているのにマイクロソフトが送られてこない -> 事前に必要なフィード変数を渡しておく
      @feed_items = current_user.feed.paginate(page: params[:page])
      render 'static_pages/home'
    end
  end

  def destroy
    @micropost.destroy
    flash[:success] = "Micropost deleted"
    # 一個前のURLにリダイレクトするかroot画面に遷移
    # redirect_to request.referrer || root_url
    # このメソッドはRails 5から新たに導入
    redirect_back(fallback_location: root_url)
  end

  private
  
    def micropost_params
      params.require(:micropost).permit(:content)
    end

    def correct_user
      # パラメーターから自分のマイクロポストのみを取得している -> 自動的に自分のマイクロポストのみしか参照、変更出来ない
      @micropost = current_user.microposts.find_by(id: params[:id])

      # マイクロポストが存在しなかったら、ルートに遷移
      redirect_to root_url if @micropost.nil?
    end
end
