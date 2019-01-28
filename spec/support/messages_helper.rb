module MessagesHelper
  def example_templates
    [{
      "id": "#{Faker::Number.number(4)}-#{Faker::Number.number(4)}-#{Faker::Number.number(4)}-#{Faker::Number.number(4)}",
      "name": Faker::HitchhikersGuideToTheGalaxy.planet,
      "body": Faker::HitchhikersGuideToTheGalaxy.quote
    }, {
      "id": "#{Faker::Number.number(4)}-#{Faker::Number.number(4)}-#{Faker::Number.number(4)}-#{Faker::Number.number(4)}",
      "name": Faker::HitchhikersGuideToTheGalaxy.planet,
      "body": Faker::HitchhikersGuideToTheGalaxy.quote
    }]
  end
end
