FactoryBot.define do
  factory :post do
    contents { Faker::Lorem.characters(number:20) }
    address { Faker::Lorem.characters(number:10) }
    image {File.open("#{Rails.root}/spec/fixture/AME619sentaihikou_TP_V4.jpg")}
    user
  end
end