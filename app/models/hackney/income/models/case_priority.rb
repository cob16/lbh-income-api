module Hackney
  module Income
    module Models
      class CasePriority < ApplicationRecord
        belongs_to :assigned_user, class_name: 'Hackney::Income::Models::User', optional: true

        def paused?
          is_paused_until ? is_paused_until.future? : false
        end

        def self.not_paused
          where('is_paused_until < ? OR is_paused_until is null', Date.today)
        end

        def self.criteria_for_green_in_arrears
          where(priority_band: 'green')
            .where('days_in_arrears >= ?', 5)
            .where('balance >= ?', 10.00)
            .where(active_agreement: false)
            .not_paused
        end
      end
    end
  end
end
