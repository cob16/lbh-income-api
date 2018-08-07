module Hackney
  module Income
    class UniversalHousingTenanciesGateway
      def tenancies_in_arrears
        tenancy_refs = []

        query = universal_housing_client.execute('SELECT tag_ref FROM tenagree WHERE cur_bal > 0')
        query.each { |record| tenancy_refs << record.fetch('tag_ref').strip }
        query.do

        tenancy_refs
      end

      private

      def universal_housing_client
        Hackney::UniversalHousing::Client.connection
      end
    end
  end
end
