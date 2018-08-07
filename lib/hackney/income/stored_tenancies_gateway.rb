module Hackney
  module Income
    class StoredTenanciesGateway
      def store_tenancy(tenancy_ref:, priority_band:, priority_score:)
        Hackney::Income::Models::Tenancy.find_or_create_by(tenancy_ref: tenancy_ref).update(
          priority_band: priority_band,
          priority_score: priority_score
        )
      end

      def get_tenancies_by_refs(refs)
        Hackney::Income::Models::Tenancy.where('tenancy_ref in (?)', refs).map do |model|
          {
            tenancy_ref: model.tenancy_ref,
            priority_band: model.priority_band,
            priority_score: model.priority_score
          }
        end
      end
    end
  end
end
