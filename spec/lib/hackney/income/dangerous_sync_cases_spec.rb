require_relative '../../../../lib/hackney/income/dangerous_sync_cases'

describe Hackney::Income::DangerousSyncCases do
  let(:uh_tenancies_gateway) { double(tenancies_in_arrears: []) }
  let(:stored_tenancies_gateway) { double(store_tenancy: nil) }
  let(:prioritisation_gateway) { PrioritisationGatewayDouble.new }

  let(:sync_cases) do
    described_class.new(
      prioritisation_gateway: prioritisation_gateway,
      uh_tenancies_gateway: uh_tenancies_gateway,
      stored_tenancies_gateway: stored_tenancies_gateway
    )
  end

  subject { sync_cases.execute }

  context 'when syncing cases' do
    context 'and finding no cases' do
      it 'should sync nothing' do
        expect(stored_tenancies_gateway).not_to receive(:store_tenancy)
        subject
      end
    end

    context 'and finding a case' do
      let(:uh_tenancies_gateway) { double(tenancies_in_arrears: ['000009/01']) }
      let(:prioritisation_gateway) do
        PrioritisationGatewayDouble.new(
          '000009/01' => { priority_band: :green, priority_score: 1000 }
        )
      end

      it 'should sync the case\'s priority score' do
        expect(stored_tenancies_gateway).to receive(:store_tenancy).with(
          tenancy_ref: '000009/01',
          priority_band: :green,
          priority_score: 1000
        )

        subject
      end
    end

    context 'and finding a different case' do
      let(:uh_tenancies_gateway) { double(tenancies_in_arrears: ['000010/01']) }
      let(:prioritisation_gateway) do
        PrioritisationGatewayDouble.new(
          '000010/01' => { priority_band: :red, priority_score: 5000 }
        )
      end

      it 'should sync the case\'s priority score' do
        expect(stored_tenancies_gateway).to receive(:store_tenancy).with(
          tenancy_ref: '000010/01',
          priority_band: :red,
          priority_score: 5000
        )

        subject
      end
    end

    context 'and finding a few cases' do
      let(:uh_tenancies_gateway) do
        double(tenancies_in_arrears: ['000010/01', '000011/01', '000012/01'])
      end

      let(:prioritisation_gateway) do
        PrioritisationGatewayDouble.new(
          '000010/01' => { priority_band: :red, priority_score: 300 },
          '000011/01' => { priority_band: :green, priority_score: 100 },
          '000012/01' => { priority_band: :amber, priority_score: 200 },
        )
      end

      it 'should sync the cases priority scores' do
        expect(stored_tenancies_gateway).to receive(:store_tenancy).with(
          tenancy_ref: '000010/01',
          priority_band: :red,
          priority_score: 300
        )

        expect(stored_tenancies_gateway).to receive(:store_tenancy).with(
          tenancy_ref: '000011/01',
          priority_band: :green,
          priority_score: 100
        )

        expect(stored_tenancies_gateway).to receive(:store_tenancy).with(
          tenancy_ref: '000012/01',
          priority_band: :amber,
          priority_score: 200
        )

        subject
      end
    end
  end
end

class PrioritisationGatewayDouble
  def initialize(tenancy_refs_to_scores = {})
    @tenancy_refs_to_scores = tenancy_refs_to_scores
  end

  def priorities_for_tenancy(tenancy_ref)
    {
      priority_score: @tenancy_refs_to_scores.dig(tenancy_ref, :priority_score),
      priority_band: @tenancy_refs_to_scores.dig(tenancy_ref, :priority_band)
    }
  end
end
