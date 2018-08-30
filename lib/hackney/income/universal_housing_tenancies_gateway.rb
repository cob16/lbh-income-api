module Hackney
  module Income
    class UniversalHousingTenanciesGateway
      def initialize(restrict_patches: false, patches: [])
        @restrict_patches = restrict_patches
        @permitted_patches = patches
      end

      def tenancies_in_arrears
        query = database[:tenagree]
          .left_join(:property, prop_ref: :prop_ref)
          .where { Sequel[:tenagree][:cur_bal] > 0 }

        if @restrict_patches
          query = query.where(Sequel[:property][:arr_patch] => @permitted_patches)
        end

        query
          .select { Sequel[:tenagree][:tag_ref].as(:tag_ref) }
          .map { |record| record[:tag_ref].strip }
      end

      private

      def database
        Hackney::UniversalHousing::Client.connection.tap do |db|
          db.extension :identifier_mangling
          db.identifier_input_method = db.identifier_output_method = nil
        end
      end
    end
  end
end
