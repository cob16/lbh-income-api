require 'rails_helper'

describe Hackney::PDF::PreviewGenerator do
  subject do
    described_class.new(
      template_path: test_template_path
    )
  end

  let(:test_template_path) { 'spec/lib/hackney/pdf/test_template.erb' }
  let(:test_letter_params) do
    {
      payment_ref: '1234567890',
      lessee_full_name: 'Mr Philip Banks',
      correspondence_address_1: '508 Saint Cloud Road',
      correspondence_address_2: 'Southwalk',
      correspondence_address_3: 'London',
      correspondence_postcode: 'SE1 0SW',
      lessee_short_name: 'Philip',
      property_address: '1 Hillman St, London, E8 1DY',
      arrears_letter_1_date: '20th Feb 2019',
      total_collectable_arrears_balance: '3506.90'
    }
  end

  let(:translated_html) { File.open('spec/lib/hackney/pdf/translated_test_template.html').read }

  it 'translates erb templates to html' do
    html = subject.execute(letter_params: test_letter_params)
    expect(html).to eq(translated_html)
  end
end
