require 'rails_helper'

# Aws::S3::Encryption::Client
class FakeAwsS3Client < Aws::S3::Encryption::Client
  def initialize(options = {})
    binding.pry
    super
    @client = Aws::S3::Client.new(stub_responses: true)
  end
end

describe Hackney::Cloud::Adapter::AwsS3 do
  let(:s3) { described_class.new Hackney::Cloud::EncryptionClient.new(ENV['CUSTOMER_MANAGED_KEY']).create }
  let(:filename) { 'test_key.pdf' }
  let(:file) { File.open('spec/test_files/test_pdf.pdf', 'rb') }
  let(:content) { file.read }

  let(:bucket_name) { 'hackney-docs-development' }

  context 'upload' do
    it 'is successful' do
      expect_any_instance_of(Aws::S3::Encryption::Client).to receive(:put_object).and_return(OpenStruct.new(successful?: true))

      file.rewind
      s3.upload(bucket_name: bucket_name,
                content: file.read,
                filename: filename)
    end

    context 'when there are upload errors' do
      it 'raises an exception' do
        expect_any_instance_of(Aws::S3::Encryption::Client).to receive(:put_object).and_return(OpenStruct.new(successful?: false))

        expect {
          s3.upload(bucket_name: bucket_name,
                    content: file.read,
                    filename: filename)
        }.to raise_exception('Cloud Storage Error!')
      end
    end
  end

  context 'download' do
    it 'a file from S3' do
      expect_any_instance_of(Aws::S3::Encryption::Client).to receive(:get_object).and_return(OpenStruct.new(successful?: true))

      download = s3.download(bucket_name: bucket_name, filename: filename)
      expect(download).to be_successful
    end
  end
end
