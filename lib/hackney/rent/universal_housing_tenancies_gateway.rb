module Hackney
  module Rent
    class UniversalHousingTenanciesGateway
      def initialize(restrict_patches: false, patches: [])
        @restrict_patches = restrict_patches
        @permitted_patches = patches
      end

      def tenancies_in_arrears
        query = database[:tenagree]

        if @restrict_patches
          query = query
                  .left_join(:property, prop_ref: :prop_ref)
                  .where(Sequel[:property][:arr_patch] => @permitted_patches)
        end

        query
          .where { Sequel[:tenagree][:cur_bal] > 0 }
          .where(Sequel[:tenagree][:tenure] => SECURE_TENURE_TYPE)
          .where(Sequel[:tenagree][:terminated].cast(:integer) => 0)
          .select { Sequel[:tenagree][:tag_ref].as(:tag_ref) }
          .map { |record| record[:tag_ref].strip }
      end

      private

      SECURE_TENURE_TYPE = 'SEC'.freeze

      def database
        Hackney::UniversalHousing::Client.connection.tap do |db|
          db.extension :identifier_mangling
          db.identifier_input_method = db.identifier_output_method = nil
        end
      end
    end
  end
end
