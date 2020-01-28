namespace :income do
  namespace :messages do
    desc 'enqueues message jobs for tenancies that match criteria of green_in_arrears'
    task :enqueue do
      use_case_factory = Hackney::Income::UseCaseFactory.new
      use_case_factory.schedule_send_sms.execute
    end
  end
end
