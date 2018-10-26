module Hackney
  module Income
    module Models
      class Tenancy < ApplicationRecord
        belongs_to :assigned_user, class_name: 'Hackney::Income::Models::User', optional: true

        def paused?
          is_paused_until ? is_paused_until.future? : false
        end
      end
    end
  end
end
