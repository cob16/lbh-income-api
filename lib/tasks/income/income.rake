namespace :income do
  namespace :tasks do
    desc 'Manual task, list all tenancies that match criteria for green in arrears messages'
    task :show_send_sms_tenancies do |_task|
      use_case_factory = Hackney::Income::UseCaseFactory.new
      tenancy_refs = use_case_factory.show_send_sms_tenancies.execute.pluck(:tenancy_ref)
      puts '---'
      tenancy_refs.each do |ref|
        puts ref
      end
      puts '---'
    end
  end
end
