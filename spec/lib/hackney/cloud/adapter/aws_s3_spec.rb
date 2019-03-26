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
    it 'a file from S3' do
      expect_any_instance_of(Aws::S3::Encryption::Client).to receive(:get_object).and_return('tmp/test_key.pdf')

      download = s3.download(bucket_name: bucket_name, filename: filename)
      expect(download).to eq 'tmp/test_key.pdf'
    end
  end
end
