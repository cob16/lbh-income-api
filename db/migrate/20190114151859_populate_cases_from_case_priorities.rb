class PopulateCasesFromCasePriorities < ActiveRecord::Migration[5.1]
  def self.up
    Hackney::Income::Models::CasePriority.all.each { |case_priority|
      case_priority.create_case!(tenancy_ref: case_priority.tenancy_ref)
    }
  end

  def self.down
    Hackney::Income::Models::CasePriority.all.each { |case_priority|
      case_priority.case.destroy! if case_priority.case
    }
  end
end
