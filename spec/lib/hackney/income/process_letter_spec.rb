require 'rails_helper'

describe Hackney::Income::ProcessLetter do
  let(:pdf_generator) { instance_double(Hackney::PDF::Generator) }
  let(:cloud_storage) { instance_double(Hackney::Cloud::Storage) }

  let(:subject) { described_class.new(pdf_generator: pdf_generator, cloud_storage: cloud_storage) }
  let(:user_id) { Faker::Number.number }
  let(:html) { "<h1>#{Faker::RickAndMorty.quote}</h1>" }
  let(:uuid) { SecureRandom.uuid }


  let(:pdf_file) { File.open('spec/test_files/test_pdf.pdf', 'rb') }

  before do
    Rails.cache.write(uuid, html)
    allow(File).to receive(:delete)
  end

  it 'calls storage.save' do
    expect(pdf_generator).to receive(:execute).with(html).and_return(FakePDFKit.new(pdf_file))

    expect(cloud_storage).to receive(:save).with(
      file: pdf_file,
      uuid: uuid,
      metadata: { user_id: user_id}
    )

    subject.execute(uuid: uuid, user_id: user_id)
  end

  it 'creates pdf' do
    allow(cloud_storage).to receive(:save)
    expect(pdf_generator).to receive(:execute).with(html).and_return(FakePDFKit.new(pdf_file))

    subject.execute(uuid: uuid, user_id: user_id)
  end
end

class FakePDFKit
  def initialize(return_file)
    @return_file = return_file
  end

  def to_file(html)
    @return_file
  end
end
