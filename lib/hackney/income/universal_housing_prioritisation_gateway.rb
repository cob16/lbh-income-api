module Hackney
  module Income
    class UniversalHousingPrioritisationGateway
      def priorities_for_tenancy(tenancy_ref)
        Hackney::UniversalHousing::Client.with_connection do |database|
          criteria = Hackney::Income::TenancyPrioritiser::UniversalHousingCriteria.for_tenancy(database, tenancy_ref)
          weightings = Hackney::Income::TenancyPrioritiser::PriorityWeightings.new
          prioritiser = Hackney::Income::TenancyPrioritiser.new(criteria: criteria, weightings: weightings)
          { priority_score: prioritiser.priority_score, priority_band: prioritiser.priority_band, criteria: criteria, weightings: weightings }
        end
      end
    end
  end
end
