require 'rails_helper'

describe Hackney::Cloud::Adapter::AwsS3 do
  subject(:s3) { described_class.new(encryption_client_double) }

  let(:encryption_client_double) { double }

  let(:filename) { "#{SecureRandom.uuid}.pdf" }
  let(:file) { File.open('spec/test_files/test_pdf.pdf', 'rb') }
  let(:content) { file.read }

  context 'when there are NOT upload errors' do
    let(:upload_response) { double(successful?: true) }

    it 'successfully uploads the S3' do
      allow(encryption_client_double).to receive(:put_object)
        .with(body: content, bucket: 'my-bucket', key: filename)
        .and_return(upload_response)

      file.rewind

      expect(
        s3.upload(bucket_name: 'my-bucket',
                  content: file.read,
                  filename: filename)
      ).to be true
    end
  end

  context 'when there are upload errors' do
    let(:upload_response) { double(successful?: false) }

    it 'raises an exception' do
      allow(encryption_client_double).to receive(:put_object)
        .with(body: content, bucket: 'my-bucket', key: filename)
        .and_return(upload_response)

      file.rewind

      expect {
        s3.upload(bucket_name: 'my-bucket',
                  content: file.read,
                  filename: filename)
      }.to raise_exception('Cloud Storage Error!')
    end
  end

  it 'downloads a file from S3' do
    expect(encryption_client_double).to receive(:get_object)
      .with(bucket: 'my-bucket', key: filename)

    s3.download('my-bucket', filename)
  end
end
