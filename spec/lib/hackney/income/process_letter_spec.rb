require 'rails_helper'

describe Hackney::Income::ProcessLetter do
  let(:pdf_generator) { instance_double(Hackney::PDF::Generator) }
  let(:cloud_storage) { instance_double(Hackney::Cloud::Storage) }

  let(:subject) { described_class.new(pdf_generator: pdf_generator, cloud_storage: cloud_storage) }
  let(:user_id) { Faker::Number.number }
  let(:html) { "<h1>#{Faker::RickAndMorty.quote}</h1>" }
  let(:uuid) { SecureRandom.uuid }

  before do
    Rails.cache.write(uuid, html)
  end

  it 'calls storage.save' do
    expect(pdf_generator).to receive(:execute).with(html).and_return(html)
    expect(cloud_storage).to receive(:save).with(
      pdf: html,
      metadata: { user_id: user_id }
    )

    subject.execute(uuid: uuid, user_id: user_id)
  end

  it 'creates pdf' do
    allow(cloud_storage).to receive(:save)
    expect(pdf_generator).to receive(:execute).with(html)

    subject.execute(uuid: uuid, user_id: user_id)
  end
end
