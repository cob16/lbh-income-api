require 'rails_helper'

describe Hackney::PDF::PDFGenerator do
  subject do
    described_class.new(
      template_path: test_template_path,
      pdf_gateway: pdf_gateway
    )
  end

  let(:pdf_gateway) { instance_double(Hackney::PDF::PDFGateway) }
  let(:test_template_path) { 'spec/lib/hackney/pdf/test_template.erb' }
  let(:test_letter_params) do
    {

      payment_ref: '1234567890',
      lessee_full_name: 'Mr Philip Banks',
      correspondence_address_one: '508 Saint Cloud Road',
      correspondence_address_two: 'Southwalk',
      correspondence_address_three: 'London',
      correspondence_postcode: 'SE1 0SW',
      lessee_short_name: 'Philip',
      property_address: '1 Hillman St, London, E8 1DY',
      arrears_letter_1_date: '20th Feb 2019',
      total_collectable_arrears_balance: '350690'

    }
  end

  let(:translated_html) { File.open('spec/lib/hackney/pdf/translated_test_template.html').read }

  it 'passes the required translated html through to the gateway' do
    expect(pdf_gateway).to receive(:generate_pdf).with(translated_html)

    subject.execute(letter_params: test_letter_params)
  end
end
