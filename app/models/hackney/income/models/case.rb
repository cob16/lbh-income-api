module Hackney
  module Income
    module Models
      class Case < ApplicationRecord
        has_one :case_priority, class_name: 'Hackney::Income::Models::CasePriority'
      end
    end
  end
end
