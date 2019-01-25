FactoryBot.define do
  factory :estimate do
    name { Faker::StarWars.character}
    optimistic { Faker::Number.between(1, 10) }
    realistic { Faker::Number.between(1, 10) }
    pessimistic { Faker::Number.between(1, 10) }
    note {Faker::StarWars.wookie_sentence}
  end
end
