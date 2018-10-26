require_relative '../../../../lib/hackney/income/hardcoded_tenancies_gateway'

describe Hackney::Income::HardcodedTenanciesGateway do
  let(:gateway) { described_class.new }

  context 'retrieving tenancy refs for cases in arrears' do
    subject { gateway.tenancies_in_arrears }

    context 'when hardcoded tenancies set in ENV' do
      before do
        @hardcoded_tenancies = ENV['HARDCODED_TENANCIES']
        ENV['HARDCODED_TENANCIES'] = '1,2,3'
      end

      after do
        ENV['HARDCODED_TENANCIES'] = @hardcoded_tenancies
      end

      it 'should return 3 hardcoded tenancies' do
        expect(subject.count).to eq(3)
      end
    end

    context 'when hardcoded tenancies not set in ENV' do
      it 'should raise error' do
        expect { subject }.to raise_error(Hackney::Income::HardcodedTenanciesUndefinedError)
      end
    end
  end
end
