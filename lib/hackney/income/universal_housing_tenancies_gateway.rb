module Hackney
  module Income
    class UniversalHousingTenanciesGateway
      def tenancies_in_arrears
        tenancy_refs = []
        query = database.execute('SELECT tag_ref FROM tenagree WHERE cur_bal > 0')
        query.each { |record| tenancy_refs << record.fetch('tag_ref').strip }
        query.do
        tenancy_refs
      end

      private

      def database
        Hackney::UniversalHousing::Client.connection
      end
    end
  end
end
