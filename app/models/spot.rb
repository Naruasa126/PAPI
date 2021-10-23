class Spot < ApplicationRecord
  belongs_to :review_id
  belongs_to :post
  geocoded_by :address
  after_validation :geocode
end
