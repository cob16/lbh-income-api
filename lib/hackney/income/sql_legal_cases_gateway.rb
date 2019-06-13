module Hackney
  module Income
    class SqlLegalCasesGateway
      def get_tenancies_for_legal_process_for_patch(patch:)
        Hackney::UniversalHousing::Client.with_connection do |database|
          database.extension :identifier_mangling
          database.identifier_input_method = database.identifier_output_method = nil
          query = database[:tenagree]

        query
          .left_join(:property, prop_ref: :prop_ref)
          .where(Sequel[:property][:arr_patch] => patch.upcase)
          .where(Sequel[:tenagree][:tenure] => SECURE_TENURE_TYPE)
          .where(Sequel[:tenagree][:terminated].cast(:integer) => 0)
          .where(Sequel[:tenagree][:high_action] => LEGAL_STAGES)
          .select { Sequel[:tenagree][:tag_ref].as(:tag_ref) }
          .map { |record| record[:tag_ref].strip }
        end
      end

      private

      LEGAL_STAGES = %w[4RS 5RP 6RC 6RO 7RE].freeze
      SECURE_TENURE_TYPE = 'SEC'.freeze
    end
  end
end
