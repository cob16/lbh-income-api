require 'rails_helper'

describe Hackney::Cloud::Jobs::SaveToCloudJob do
  subject { described_class }

  let(:file) { File.open('spec/test_files/test_pdf.pdf', 'rb') }
  let(:bucket_name) { 'my-bucket' }
  let(:file_name) { File.basename(file) }

  it 'uploads to clouds' do
    doc = Hackney::Cloud::Document.create(filename: 'my-doc.pdf')

    subject.perform_now(bucket_name: bucket_name,
                        filename: file_name,
                        content: file.read,
                        document_id: doc.id)

    uploaded_doc = Hackney::Cloud::Document.find(doc.id)

    expect(uploaded_doc.url).to eq "https://#{bucket_name}/#{file_name}"
    expect(uploaded_doc.status).to eq('uploaded')
  end
end
