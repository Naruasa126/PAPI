FactoryBot.define do
  factory :factory do
    association :post
    user { post.user }
  end
end