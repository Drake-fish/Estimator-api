FactoryBot.define do
  factory :estimate do
    name { Faker::StarWars.character}
    optimistic { Faker::Number.number(10) }
    realistic { Faker::Number.number(10) }
    pessimistic { Faker::Number.number(10) }
    note {Faker::StarWars.wookie_sentence}
  end
end
