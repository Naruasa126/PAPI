class Post < ApplicationRecord
   acts_as_taggable
   belongs_to :user
   attachment :image
   has_many :post_comments, dependent: :destroy
   has_many :favorites, dependent: :destroy
   has_many :favorited_users, through: :favorites, source: :user
   has_one :map, dependent: :destroy
   validates :contents, presence: true
   validates :image, presence: true
   validates :address, presence: true

   def favorited_by?(user)
    favorites.where(user_id: user.id).exists?
   end
end
