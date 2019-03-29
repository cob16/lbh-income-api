require 'rails_helper'

describe Hackney::Income::Jobs::SaveAndSendLetterJob do
  include ActiveJob::TestHelper

  # let(:file) { File.open('spec/test_files/test_pdf.pdf', 'rb') }
  # let(:stringio) { StringIO.new(file.read)}
  let(:file_name) { 'test_pdf.pdf' }
  let(:bucket_name) { 'my-bucket' }
  let(:letter_html) { "<h1>#{Faker::RickAndMorty.quote}</h1>" }

  let(:doc) { Hackney::Cloud::Document.create(filename: 'my-doc.pdf') }

  let(:enqueue_save_send) {
    described_class.perform_now(bucket_name: bucket_name,
                                filename: file_name,
                                letter_html: letter_html,
                                document_id: doc.id)
  }

  before {
    expect_any_instance_of(Aws::S3::Encryption::Client).to receive(:put_object).and_return(AwsEncryptionClientDouble.new(nil).send(:put_object))
  }

  it 'uploads to clouds' do
    expect_any_instance_of(Aws::S3::Encryption::Client).to receive(:get_object).and_return(AwsClientResponse.new)
    expect_any_instance_of(Hackney::Notification::GovNotifyGateway).to receive(:send_precompiled_letter).once

    enqueue_save_send
    uploaded_doc = Hackney::Cloud::Document.find(doc.id)
    expect(uploaded_doc.url).to eq 'blah.com'
    expect(uploaded_doc.status).to eq('uploaded')
  end

  it 'perform_now on SendLetterToGovNotifyJob' do
    expect_any_instance_of(Hackney::Income::Jobs::SendLetterToGovNotifyJob).to receive(:perform_now).once
    enqueue_save_send
  end

# TODO:
    # expect(pdf_generator).to receive(:execute).with(html).and_return(FakePDFKit.new(pdf_file))
  # it 'creates pdf' do
  #   allow(cloud_storage).to receive(:save)
  #   expect(pdf_generator).to receive(:execute).with(html).and_return(FakePDFKit.new(pdf_file))

  #   subject.execute(uuid: uuid, user_id: user_id)
  # end

  xit 'enqueues sending to gov notify for delivery' do
    # TODO: problem with perform_later from within SaveAndSendLetterJob
    expect {
      enqueue_save_send
    }.to(have_enqueued_job(Hackney::Income::Jobs::SendLetterToGovNotifyJob).with { |params|
      expect(params[:document_id]).to be_present
    })
  end
end
