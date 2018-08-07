module Hackney
  module Income
    class UniversalHousingPrioritisationGateway
      def priorities_for_tenancy(tenancy_ref)
        universal_housing_client = Hackney::UniversalHousing::Client.connection
        criteria = Hackney::Income::TenancyPrioritiser::UniversalHousingCriteria.for_tenancy(universal_housing_client, tenancy_ref)
        weightings = Hackney::Income::TenancyPrioritiser::PriorityWeightings.new
        prioritiser = Hackney::Income::TenancyPrioritiser.new(criteria: criteria, weightings: weightings)

        { priority_score: prioritiser.priority_score, priority_band: prioritiser.priority_band }
      end
    end
  end
end
