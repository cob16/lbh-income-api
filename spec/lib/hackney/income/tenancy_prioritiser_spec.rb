require 'rails_helper'

describe Hackney::Income::TenancyPrioritiser do
  let(:criteria) { Hackney::Income::TenancyPrioritiser::StubCriteria.new }
  let(:weightings) { Hackney::Income::TenancyPrioritiser::PriorityWeightings.new }

  let(:subject) { described_class.new(criteria: criteria, weightings: weightings) }

  context 'when retrieving priority score' do
    let(:priority_score) { Faker::Number.number(2).to_i }

    it 'should generate a score assigner and pass it its criteria' do
      expect(Hackney::Income::TenancyPrioritiser::Score).to receive(:new).with(criteria, weightings).and_call_original
      expect_any_instance_of(Hackney::Income::TenancyPrioritiser::Score).to receive(:execute)

      subject.priority_score
    end

    it 'return the score assigner\'s score' do
      allow_any_instance_of(Hackney::Income::TenancyPrioritiser::Score).to receive(:execute).and_return(priority_score)

      expect(subject.priority_score).to eq(priority_score)
    end
  end

  context 'when generating a priority band' do
    let(:priority_band) { Faker::Dog.size.to_sym }

    it 'should generate a band assigner and pass it its criteria' do
      expect(Hackney::Income::TenancyPrioritiser::Band).to receive(:new).with(criteria).and_call_original
      expect_any_instance_of(Hackney::Income::TenancyPrioritiser::Band).to receive(:execute)

      subject.priority_band
    end

    it 'should return the band assigner\'s band' do
      allow_any_instance_of(Hackney::Income::TenancyPrioritiser::Band).to receive(:execute).and_return(priority_band)

      expect(subject.priority_band).to eq(priority_band)
    end
  end

  context 'when using the score to drive band changes in edge cases' do
    before do
      allow_any_instance_of(Hackney::Income::TenancyPrioritiser::Score).to receive(:execute).and_return(computed_priority_score)
      allow_any_instance_of(Hackney::Income::TenancyPrioritiser::Band).to receive(:execute).and_return(computed_priority_band)
    end

    context 'and an otherwise green case scores not quite high enough to adjust its score' do
      let(:computed_priority_score) { described_class::AMBER_SCORE_THRESHOLD }
      let(:computed_priority_band) { :green }

      it 'stays green' do
        expect(subject.priority_band).to eq(:green)
      end
    end

    context 'and an otherwise green case scores high enough to adjust its score' do
      let(:computed_priority_score) { described_class::AMBER_SCORE_THRESHOLD + 1 }
      let(:computed_priority_band) { :green }

      it 'reassigns to amber' do
        expect(subject.priority_band).to eq(:amber)
      end
    end

    context 'when a case is green but score would drive band to amber but maintaining an agreement' do
      let(:computed_priority_score) { described_class::AMBER_SCORE_THRESHOLD + 1 }
      let(:computed_priority_band) { :green }

      it 'stays green' do
        criteria.active_agreement = true
        expect(subject.priority_band).to eq(:green)
      end
    end

    context 'and an otherwise amber case scores not quite high enough to adjust its score' do
      let(:computed_priority_score) { described_class::RED_SCORE_THRESHOLD }
      let(:computed_priority_band) { :amber }

      it 'stays amber' do
        expect(subject.priority_band).to eq(:amber)
      end
    end

    context 'and an otherwise amber case scores high enough to adjust its score' do
      let(:computed_priority_score) { described_class::RED_SCORE_THRESHOLD + 1 }
      let(:computed_priority_band) { :amber }

      it 'reassigns to red' do
        expect(subject.priority_band).to eq(:red)
      end
    end
  end
end
