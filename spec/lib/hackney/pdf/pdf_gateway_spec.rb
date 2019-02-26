require 'rails_helper'

describe Hackney::PDF::PDFGateway do
  let(:gateway) { described_class.new }
  let(:html) { "<h1>#{Faker::RickAndMorty.quote}</h1>" }

  context 'when generating a pdf' do
    subject do
      gateway.generate_pdf(html)
    end

    it 'pdf should have the right options' do
      expect(subject.options).to eq(
        '--quiet' => nil,
        '--page-size' => 'A4',
        '--margin-top' => '0.19685in',
        '--margin-right' => '0.590551in',
        '--margin-bottom' => '0.19685in',
        '--margin-left' => '0.590551in',
        '--encoding' => 'UTF-8'
      )
    end

    it 'pdf has the right source' do
      expect(subject.source.instance_values['source']).to eq(html)
    end
  end
end
