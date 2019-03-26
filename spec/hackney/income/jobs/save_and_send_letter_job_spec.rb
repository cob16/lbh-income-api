require 'rails_helper'

describe Hackney::Income::Jobs::SaveAndSendLetterJob do
  include ActiveJob::TestHelper
  subject { described_class }

  let(:file) { File.open('spec/test_files/test_pdf.pdf', 'rb') }
  let(:bucket_name) { 'my-bucket' }
  let(:file_name) { File.basename(file) }

  let(:doc) { Hackney::Cloud::Document.create(filename: 'my-doc.pdf') }

  let(:enqueue_save_send) {
    subject.perform_now(bucket_name: bucket_name,
                        filename: file_name,
                        content: file.read,
                        document_id: doc.id)
  }

  before {
    expect_any_instance_of(Aws::S3::Encryption::Client).to receive(:put_object).and_return(AwsEncryptionClientDouble.new(nil).send(:put_object))
  }

  it 'uploads to clouds' do
    enqueue_save_send
    uploaded_doc = Hackney::Cloud::Document.find(doc.id)
    expect(uploaded_doc.url).to eq 'blah.com'
    expect(uploaded_doc.status).to eq('uploaded')
  end

  it 'enqueues sending to gov notify for delivery' do
    expect { enqueue_save_send }.to enqueue_job(Hackney::Income::Jobs::SendLetterToGovNotifyJob)
  end
end
