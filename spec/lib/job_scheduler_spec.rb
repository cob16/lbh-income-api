require 'rails_helper'

describe JobScheduler do
  subject { described_class }

  xit 'should try and schedule the next SyncCasesJob' do
    expect(Hackney::Income::Jobs::SyncCasesJob).to receive(:enqueue_next)
    subject.enqueue_jobs
  end
end
