namespace :rent do
  namespace :messages do
    desc 'enqueues message jobs for tenancies that match criteria of green_in_arrears'
    task :enqueue do
      use_case_factory = Hackney::Rent::UseCaseFactory.new
      use_case_factory.schedule_green_in_arrears_message.execute
    end
  end
end
