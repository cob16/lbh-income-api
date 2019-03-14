module Hackney
  module Rent
    class UniversalHousingPrioritisationGateway
      def priorities_for_tenancy(tenancy_ref)
        universal_housing_client = Hackney::UniversalHousing::Client.connection
        criteria = Hackney::Rent::TenancyPrioritiser::UniversalHousingCriteria.for_tenancy(universal_housing_client, tenancy_ref)
        weightings = Hackney::Rent::TenancyPrioritiser::PriorityWeightings.new
        prioritiser = Hackney::Rent::TenancyPrioritiser.new(criteria: criteria, weightings: weightings)

        { priority_score: prioritiser.priority_score, priority_band: prioritiser.priority_band, criteria: criteria, weightings: weightings }
      end
    end
  end
end
