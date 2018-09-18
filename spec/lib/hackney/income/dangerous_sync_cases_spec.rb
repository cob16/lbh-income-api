require_relative '../../../../lib/hackney/income/dangerous_sync_cases'

describe Hackney::Income::DangerousSyncCases do
  let(:uh_tenancies_gateway) { double(tenancies_in_arrears: []) }
  let(:stored_tenancies_gateway) { double(store_tenancy: nil) }
  let(:prioritisation_gateway) { PrioritisationGatewayDouble.new }
  let(:assign_tenancy_to_user) { double(assign_tenancy_to_user: nil) }

  let(:sync_cases) do
    described_class.new(
      prioritisation_gateway: prioritisation_gateway,
      uh_tenancies_gateway: uh_tenancies_gateway,
      stored_tenancies_gateway: stored_tenancies_gateway,
      assign_tenancy_to_user: assign_tenancy_to_user
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
          priority_score: 1000,
          criteria: an_instance_of(Hackney::Income::TenancyPrioritiser::StubCriteria),
          weightings: an_instance_of(Hackney::Income::TenancyPrioritiser::PriorityWeightings)
        )

        expect(assign_tenancy_to_user).to receive(:assign)

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
          priority_score: 5000,
          criteria: an_instance_of(Hackney::Income::TenancyPrioritiser::StubCriteria),
          weightings: an_instance_of(Hackney::Income::TenancyPrioritiser::PriorityWeightings)
        )

        expect(assign_tenancy_to_user).to receive(:assign)

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
          priority_score: 300,
          criteria: an_instance_of(Hackney::Income::TenancyPrioritiser::StubCriteria),
          weightings: an_instance_of(Hackney::Income::TenancyPrioritiser::PriorityWeightings)
        )

        expect(stored_tenancies_gateway).to receive(:store_tenancy).with(
          tenancy_ref: '000011/01',
          priority_band: :green,
          priority_score: 100,
          criteria: an_instance_of(Hackney::Income::TenancyPrioritiser::StubCriteria),
          weightings: an_instance_of(Hackney::Income::TenancyPrioritiser::PriorityWeightings)
        )

        expect(stored_tenancies_gateway).to receive(:store_tenancy).with(
          tenancy_ref: '000012/01',
          priority_band: :amber,
          priority_score: 200,
          criteria: an_instance_of(Hackney::Income::TenancyPrioritiser::StubCriteria),
          weightings: an_instance_of(Hackney::Income::TenancyPrioritiser::PriorityWeightings)
        )

        expect(assign_tenancy_to_user).to receive(:assign).exactly(3).times

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
      priority_band: @tenancy_refs_to_scores.dig(tenancy_ref, :priority_band),
      criteria: Hackney::Income::TenancyPrioritiser::StubCriteria.new,
      weightings: Hackney::Income::TenancyPrioritiser::PriorityWeightings.new
    }
  end
end
