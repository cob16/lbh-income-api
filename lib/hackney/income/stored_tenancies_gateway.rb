module Hackney
  module Income
    class StoredTenanciesGateway
      def store_tenancy(tenancy_ref:, priority_band:, priority_score:)
        Hackney::Income::Models::Tenancy.find_or_create_by(tenancy_ref: tenancy_ref).update(
          priority_band: priority_band,
          priority_score: priority_score
        )
      end
    end
  end
end
