class User < ApplicationRecord

  # dependentはuserが削除されたときにpostを削除することを保証する
  has_many :microposts, dependent: :destroy

  # フォローする側の情報
  has_many :active_relationships, class_name:  "Relationship",
                                  foreign_key: "follower_id",
                                  dependent:   :destroy # ユーザーが削除したら、自動的に他のユーザーとの関係性を削除する
  # following配列のもとはfollowedIDの集合である -> followedsだと不適切
  has_many :following, through: :active_relationships, source: :followed


  # フォローされる側の情報
  has_many :passive_relationships,  class_name:  "Relationship",
                                    foreign_key: "followed_id",
                                    dependent:   :destroy
  # followersが英語的に正しいため、sourceは削除しても良い(一応明示的に)
  has_many :followers, through: :passive_relationships, source: :follower



  attr_accessor :remember_token, :activation_token, :reset_token
  before_save   :downcase_email
  before_create :create_activation_digest


  # バリデーション

  validates :name,  
    presence: true, 
    length: { maximum: 50 }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, 
    presence: true, 
    length: { maximum: 255 }, 
    format: { with: VALID_EMAIL_REGEX }, 
    uniqueness: { case_sensitive: false }

  # オブジェクト生成時にパスワードの存在性を検証する
  has_secure_password
  validates :password,  
    presence: true, 
    length: { minimum: 6 },
    allow_nil: true

  ######

  # メソッド

  # 渡された文字列のハッシュ値を返す -> new_tokenメソッドよりランダムな文字列をハッシュ値にして返す
  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end 

  # ランダムなトークンを返す
  def self.new_token
    SecureRandom.urlsafe_base64
  end

  # 永続セッションのためにユーザーをデータベースに記憶する
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # 渡されたトークン(ブラウザ側)がダイジェスト(DB側)と一致したらtrueを返す
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)
  end

  # アカウントを有効にする
  def activate
    # user. の記法を使用していないところに注意
    # Userモデル内にuser変数は存在しないため
    # update_attribute(:activated, true)
    # update_attribute(:activated_at, Time.zone.now)

    # 改良版(update_attributeと違って、モデルのコールバックやバリデーション処理がされないため注意)
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  # 有効化用のメールを送信する
  def send_activation_email
    # selfにすることで、@user.send_activation_emailの@userが参照されメール送信処理がされる
    # deliver_nowメソッドによってUserMailer.account_activation(@user)がメール内容として送信される
    # deliver_nowはメーラーの埋め込み関数
    # mailers/user_mailer.rb参照
    UserMailer.account_activation(self).deliver_now
  end

  # パスワード再設定の属性を設定する
  def create_reset_digest
    # Userクラスのreset_tokenだからself
    # tokenを作成
    self.reset_token = User.new_token

    # ユーザーのリセット情報を更新する
    # update_attribute(:reset_digest, User.digest(reset_token))
    # update_attribute(:reset_sent_at, Time.zone.now)
    # ↓↓↓ サーバーにアクセスする回数を1回に節約できる ↓↓↓
    update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
  end

  # パスワード再設定用のメールを送信
  def send_password_reset_email
    # mailers/user_mailer.rb参照
    UserMailer.password_reset(self).deliver_now
  end

  # パスワード再設定の期限が切れている場合はtrueを返す
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  # 試作feedの定義
  def feed
    # フォローしているすべてのユーザーのDBに問い合わせ、投稿を取得する -> 遅い
    # Micropost.where("user_id IN (?) OR user_id = ?", following_ids, id)

    # Micropost.where("user_id IN (:following_ids) OR user_id = :user_id", following_ids: following_ids, user_id: id)

    # # ユーザー(id=1)がフォローしている全ユーザーと...
    # following_ids = "SELECT followed_id from relationships WHERE follower_id = :user_id"
    # # 自分自身のマイクロソフトを取得
    # Micropost.where("user_id IN (#{following_ids}) OR user_id = :user_id", user_id: id)


    part_of_feed = "relationships.follower_id = :id or microposts.user_id = :id"
    Micropost
      .left_outer_joins(user: :followers) # 外部DBと結合
      .where(part_of_feed, { id: id }).distinct # distinct によって重複を削除する
      .includes(:user, image_attachment: :blob) 
      # image_attachment -> Active Storageによって追加された関連付けの名前
      # blog -> ファイルに関するメタデータ、どこに存在するファイルなのかのキーを含むレコード
      # N+1問題に対応するため(大量のSQLの発行を抑える?)
  end

  # 他ユーザーをフォローする
  def follow(other_user)
    following << other_user
  end

  # 他ユーザーをフォロー解除する
  def unfollow(other_user) 
    active_relationships.find_by(followed_id: other_user.id).destroy
  end


  def following?(other_user)
    # following -> followedの別名
    following.include?(other_user)
  end

  private

    # メールアドレスをすべて小文字にする
    def downcase_email
      email.downcase!
    end

    # 有効化トークンとダイジェストを作成および代入する
    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end
