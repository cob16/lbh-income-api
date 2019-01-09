require 'rails_helper'

describe Hackney::Income::Jobs::AddActionDiaryEntryJob do
  subject { described_class }

  let(:mock_action_diary_usecase) { double(Hackney::Tenancy::AddActionDiaryEntry) }

  let(:tenancy_ref) { Faker::Internet.slug }
  let(:action_code) { Faker::Lorem.word }
  let(:comment) { Faker::Lorem.paragraph }

  before do
    stub_const('Hackney::Tenancy::AddActionDiaryEntry', mock_action_diary_usecase)
    allow(mock_action_diary_usecase).to receive(:new).and_return(mock_action_diary_usecase)
  end

  it 'should call usecase with correct args' do
    expect(mock_action_diary_usecase).to receive(:execute).with(
      hash_including(
        tenancy_ref: tenancy_ref,
        action_code: action_code,
        comment: comment,
        user_id: nil
      )
    ).once
    subject.perform_now(tenancy_ref: tenancy_ref, action_code: action_code, comment: comment)
  end

  it 'should be able to be scheduled' do
    expect do
      subject.set(wait_until: Time.now + 5.minutes).perform_later
    end.to_not raise_error
  end
end
