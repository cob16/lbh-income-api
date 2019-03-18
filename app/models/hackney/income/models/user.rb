module Hackney
  module Income
    module Models
      class User < ApplicationRecord
        # TODO: use appropriate convention user_id
        has_many :case_priorities, foreign_key: :assigned_user_id

        enum role: %i[base_user credit_controller legal_case_worker manager developer]

        def self.with_tenancy_counts(of_priority_band:)
          where(role: :credit_controller).all.map do |u|
            # TODO: rework .where query to use relationship
            { id: u.id, count: Hackney::Income::Models::CasePriority.where(assigned_user_id: u.id, priority_band: of_priority_band).count }
          end
        end
      end
    end
  end
end
