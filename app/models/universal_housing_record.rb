class UniversalHousingRecord < ApplicationRecord
  self.abstract_class = true
  establish_connection UNIVERSAL_HOUSING_CONFIG

  def readonly?
    not Rails.env.test?
  end
end
