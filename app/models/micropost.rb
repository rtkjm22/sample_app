class Micropost < ApplicationRecord
  belongs_to :user

  # 新しい順に取得する
  default_scope -> { order(created_at: :desc) }

  validates :user_id,
    presence: true

  validates :content,
    presence: { message: "は1文字以上入力してください。" },
    length: { maximum: 140 , message: "140文字以上入力しないでください。"}

end
