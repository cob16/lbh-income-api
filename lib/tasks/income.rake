namespace :income do
  task :sync do
    use_case_factory = Hackney::Income::UseCaseFactory.new
    use_case_factory.sync_cases.execute
  end
end
