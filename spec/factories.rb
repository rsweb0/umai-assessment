FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password { 'password' }
  end

  factory :post do
    title { Faker::Lorem.word }
    content { Faker::Lorem.paragraph }
    author_ip { Faker::Internet.unique.ip_v4_address }
    association :user
  end

  factory :rating do
    value { rand(1..5) }
    association :post
  end

  factory :feedback do
    comment { Faker::Lorem.sentence }
    association :owner, factory: :user
    association :feedable, factory: :post
  end
end
