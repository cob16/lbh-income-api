require 'rails_helper'

describe UseCases::CaseClassificationToLetterTypeMap do
  let(:use_case) { described_class.new }

  let(:letter_1_template_name) { 'income_collection_letter_1' }
  let(:letter_2_template_name) { 'income_collection_letter_2' }
  let(:classification) { nil }
  let(:case_priority) { build(:case_priority, classification: classification) }

  let(:allow_letter_one) { false }
  let(:allow_letter_two) { false }

  before do
    allow(App::Application).to receive(:feature_toggle).with('AUTOMATE_INCOME_COLLECTION_LETTER_ONE')
                                                       .and_return(allow_letter_one)
    allow(App::Application).to receive(:feature_toggle).with('AUTOMATE_INCOME_COLLECTION_LETTER_TWO')
                                                       .and_return(allow_letter_two)
  end

  context 'when the environment allows letter 1 to be sent and not letter 2' do
    let(:allow_letter_one) { true }

    context 'when the classification is `send_letter_one`' do
      let(:classification) { :send_letter_one }

      it 'returns the correct template name' do
        expect(use_case.execute(case_priority: case_priority)).to eq(letter_1_template_name)
      end
    end

    context 'when the classification is `send_letter_two`' do
      let(:classification) { :send_letter_two }

      it 'returns nil' do
        expect(use_case.execute(case_priority: case_priority)).to be_nil
      end
    end

    context 'when the classification is `send_first_SMS`' do
      let(:classification) { :send_first_SMS }

      it 'returns nil' do
        expect(use_case.execute(case_priority: case_priority)).to be_nil
      end
    end
  end

  context 'when the environment does not allow letter 1 to be sent' do
    let(:allow_letter_one) { false }

    context 'when the classification is `send_letter_one`' do
      let(:classification) { :send_letter_one }

      it 'returns nil' do
        expect(use_case.execute(case_priority: case_priority)).to be_nil
      end
    end
  end

  context 'when the environment allows letter 2 to be sent and not letter 1' do
    let(:allow_letter_two) { true }

    context 'when the classification is `send_letter_one`' do
      let(:classification) { :send_letter_one }

      it 'returns nil' do
        expect(use_case.execute(case_priority: case_priority)).to be_nil
      end
    end

    context 'when the classification is `send_letter_two`' do
      let(:classification) { :send_letter_two }

      it 'returns the correct template name' do
        expect(use_case.execute(case_priority: case_priority)).to eq(letter_2_template_name)
      end
    end

    context 'when the classification is `send_first_SMS`' do
      let(:classification) { :send_first_SMS }

      it 'returns nil' do
        expect(use_case.execute(case_priority: case_priority)).to be_nil
      end
    end
  end

  context 'when the environment does not allow letter 2 to be sent' do
    let(:allow_letter_two) { false }

    context 'when the classification is `send_letter_two`' do
      let(:classification) { :send_letter_two }

      it 'returns nil' do
        expect(use_case.execute(case_priority: case_priority)).to be_nil
      end
    end
  end
end
