module Hackney
  module Income
    module Models
      class User < ApplicationRecord
        has_many :tenancies, foreign_key: :assigned_user_id

        enum role: [ :developer, :credit_controller, :legal_case_worker, :manager ]
      end
    end
  end
end
