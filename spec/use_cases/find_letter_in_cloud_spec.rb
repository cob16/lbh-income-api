require 'rails_helper'

xdescribe UseCases::FindLetterInCloud do
  subject { described_class.new(spy_gateway) }

  let(:spy_gateway) { spy }

  context 'with letter data and bucket name' do
    let(:file_location) {
      { bucket_name: "my_bucket",
        uuid: "1234",
        pdf: "pdf data, whey"
      }
    }

    it 'passes the correct information to the gateway' do
      subject.execute(file_location: file_location)

    expect(spy_gateway).to have_received(:download).with(
      bucket_name: file_location[:bucket_name],
      key: "#{file_location[:uuid]}.pdf"
    )
    end
  end
end
