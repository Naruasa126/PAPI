class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

   attachment :image
   has_many :posts, dependent: :destroy
   has_many :post_comments, dependent: :destroy
   has_many :favorites, dependent: :destroy
   has_many :favorited_posts, through: :favorites, source: :post
   has_many :active_relationships, class_name: "Relationship", foreign_key: :following_id
   has_many :followings, through: :active_relationships, source: :follower
   has_many :passive_relationships, class_name: "Relationship", foreign_key: :follower_id
   has_many :followers, through: :passive_relationships, source: :following
   mount_uploader :image, ImageUploader
   validates :name, presence: true, length: {in: 2..20}, uniqueness: true
   validates :introduction, allow_blank: true, length: {maximum: 50}
   def followed_by?(user)
     passive_relationships.find_by(following_id: user.id).present?
   end
   def already_favorited?(post)
    self.favorites.exists?(post_id: post.id)
   end
end
