require 'rails_helper'

describe UseCases::SaveLetterToCloud do
  subject { described_class.new(spy_gateway) }

  let(:spy_gateway) { spy }

  context 'with letter data and bucket name' do
    let(:bucket_name) { 'my_bucket' }
    let(:uuid) { Faker::Lorem.characters(5) }
    let(:pdf) { 'pdf_data' }

    it 'passes the correct information to the gateway' do
      subject.execute(uuid: uuid, bucket_name: bucket_name, pdf: pdf)

    expect(spy_gateway).to have_received(:upload).with(
        bucket_name: bucket_name,
        binary_letter_content: pdf,
        filename: "#{uuid}.pdf"
      )
    end
  end

  context 'with a blank bucket name' do
    let(:bucket_name) { '' }
    let(:uuid) { Faker::Lorem.characters(5) }
    let(:pdf) { 'pdf_data' }

    it 'works' do
      expect { subject.execute(uuid: uuid, bucket_name: bucket_name, pdf: pdf) }.to raise_error(ArgumentError)
    end
  end

  context 'with a missing uuid' do
    let(:bucket_name) { 'bucket_name' }
    let(:pdf) { 'pdf_data' }

    it 'works' do
      expect { subject.execute(uuid: nil, bucket_name: bucket_name, pdf: pdf) }.to raise_error(ArgumentError)
    end
  end

  context 'with no pdf data' do
    let(:bucket_name) { 'bucket_name' }
    let(:uuid) { Faker::Lorem.characters(5) }

    it 'works' do
      expect { subject.execute(uuid: uuid, bucket_name: bucket_name, pdf: nil) }.to raise_error(ArgumentError)
    end
  end
end
