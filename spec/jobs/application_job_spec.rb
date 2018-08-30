require 'rails_helper'

describe ApplicationJob do
  context '#enqueue_next' do
    context 'when the next run is already scheduled' do
      subject { MidnightJob }

      it 'should not schedule again' do
        subject.set(wait_until: subject.next_run_time).perform_later

        expect { subject.enqueue_next }.to_not change { Delayed::Job.count }
      end
    end

    context 'when the next run time is tomorrow at lunch' do
      subject { LunchJob }

      it 'should queue the job for tomorrow at lunch' do
        subject.enqueue_next
        expect(Delayed::Job.last).to have_attributes(run_at: Date.tomorrow.noon)
      end
    end

    context 'when the next run time is tomorrow at midnight' do
      subject { MidnightJob }

      it 'should queue the job for tomorrow at midnight' do
        subject.enqueue_next
        expect(Delayed::Job.last).to have_attributes(run_at: Date.tomorrow.midnight)
      end
    end

    context 'when next run time has not been set' do
      subject { NextRunNotDefinedJob }

      it 'should raise an exception' do
        expect { subject.enqueue_next }.to raise_error(NotImplementedError)
      end
    end
  end

  class NextRunNotDefinedJob < ApplicationJob; end

  class LunchJob < ApplicationJob
    def self.next_run_time
      Date.tomorrow.noon
    end
  end

  class MidnightJob < ApplicationJob
    def self.next_run_time
      Date.tomorrow.midnight
    end
  end
end
