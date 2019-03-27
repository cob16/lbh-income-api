require 'rails_helper'

describe Hackney::Cloud::Adapter::AwsS3 do
  let(:s3) { described_class.new Hackney::Cloud::EncryptionClient.new(ENV['CUSTOMER_MANAGED_KEY']).create }
  let(:filename) { 'test_key.pdf' }
  let(:file) { File.open('spec/test_files/test_pdf.pdf', 'rb') }
  let(:content) { file.read }

  let(:bucket_name) { 'hackney-docs-development' }

  context 'when upload' do
    it 'is successful' do
      stub_const('Aws::S3::Encryption::Client', AwsEncryptionClientDouble)
      response = s3.upload(bucket_name: bucket_name,
                           content: file.read,
                           filename: filename)

      expect(response).to eq(url: 'blah.com', uploaded_at: Time.new(2002))
    end
  end

  context 'when download' do

    before do
      expect_any_instance_of(Aws::S3::Encryption::Client).to receive(:get_object).and_return(ResponseMock.new(content))
    end

    it 'a file from S3' do
      download = s3.download(bucket_name: bucket_name, filename: filename)
      expect(download).to be_a Tempfile
      expect(download.read).to eq content
    end
  end

  # rubocop:disable RSpec/InstanceVariable
  class ResponseMock
    def initialize(content)
      @content = content
    end

    def body
      OpenStruct.new(read: @content)
    end
  end
  # rubocop:enable RSpec/InstanceVariable
end
