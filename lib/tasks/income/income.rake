namespace :income do
  namespace :tasks do
    desc 'Manual task, supply a 3 character patch code and the user ID for a user in our SQL database.' \
         'All tenancies in that patch where the high action is 4RS or above will be assigned to that user.'
    task :migrate_lcw_cases, [:patch, :user_id] do |_task, args|
      use_case_factory = Hackney::Income::UseCaseFactory.new
      result = use_case_factory.migrate_patch_to_lcw.execute(patch: args.fetch(:patch), user_id: args.fetch(:user_id))
      puts '---------------'
      puts "Found #{result[:tenancy_refs_in_legal_process].length}, failed to assign: #{result[:tenancy_refs_not_found].length}"
      puts '---------------'
      puts result[:tenancy_refs_not_found]
    end

    desc 'Manual task, list all tenancies that match criteria for green in arrears messages'
    task :show_tenancies_green_in_arrears do |_task|
      use_case_factory = Hackney::Income::UseCaseFactory.new
      tenancy_refs = use_case_factory.show_green_in_arrears.execute.pluck(:tenancy_ref)
      puts '---'
      tenancy_refs.each do |ref|
        puts ref
      end
      puts '---'
    end
  end
end
