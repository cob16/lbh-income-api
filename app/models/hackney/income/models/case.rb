module Hackney
  module Income
    module Models
      class Case < ApplicationRecord
        has_one :case_priority, class_name: 'Hackney::Income::Models::CasePriority'
        validates :tenancy_ref, presence: true, uniqueness: true
      end
    end
  end
end
