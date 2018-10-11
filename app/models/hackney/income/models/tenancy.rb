module Hackney
  module Income
    module Models
      class Tenancy < ApplicationRecord
        belongs_to :assigned_user, class_name: 'Hackney::Income::Models::User', optional: true
      end
    end
  end
end
