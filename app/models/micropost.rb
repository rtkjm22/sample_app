class Micropost < ApplicationRecord
  belongs_to :user

  # アップロードされたファイルと関連付ける(今回は画像)
  has_one_attached :image

  # 新しい順に取得する
  default_scope -> { order(created_at: :desc) }

  validates :user_id,
    presence: true

  validates :content,
    presence: { message: "は1文字以上入力してください。" },
    length: { maximum: 140 , message: "140文字以上入力しないでください。"}

  validates :image, 
    content_type: {
      in: %w[image/jpeg image/gif image/png],
      message: "must be a valid image format"
    },
    size: {
      less_than: 5.megabytes,
      message: "should be less than 5MB"
    }

  # 表示用のリサイズ済み画像を返す
  def display_image
    # 500pxを超えないようにする
    image.variant(resize_to_limit: [500, 500])
  end

end
