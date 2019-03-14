class PopulateCasesFromCasePriorities < ActiveRecord::Migration[5.1]
  def self.up
    Hackney::Rent::Models::CasePriority.all.each { |case_priority|
      case_priority.create_case!(tenancy_ref: case_priority.tenancy_ref)
    }
  end

  def self.down
    Hackney::Rent::Models::CasePriority.all.each { |case_priority|
      case_priority.case&.destroy!
    }
  end
end
