require 'rails_helper'

describe Hackney::PDF::GetTemplates do
  subject do
    described_class.new
  end

  let(:test_template) {
    {
      id: 'test_template',
      name: 'Test template',
      path: 'spec/lib/hackney/pdf/test_template.erb'
    }
  }

  context 'when user is in the leasehold services group' do
    it 'templates are found in the correct directory' do
      allow(Dir).to receive(:glob)
        .with(["#{Hackney::PDF::GetTemplates::LEASEHOLD_SERVICES_TEMPLATE_DIRECTORY_PATH}*.erb"])
        .and_return([test_template[:path]])

      expect(subject.execute(user_groups: [Hackney::PDF::GetTemplates::LEASEHOLD_SERVICES_GROUP]))
        .to eq([test_template])
    end
  end

  context 'when user is in the income collection group' do
    it 'templates are found in the correct directory' do
      allow(Dir).to receive(:glob)
        .with(["#{Hackney::PDF::GetTemplates::INCOME_COLLECTION_TEMPLATE_DIRECTORY_PATH}*.erb"])
        .and_return([test_template[:path]])

      expect(subject.execute(user_groups: [Hackney::PDF::GetTemplates::INCOME_COLLECTION_GROUP]))
        .to eq([test_template])
    end
  end

  context 'when user is in the income collection and leasehold services group' do
    it 'templates are found in the correct directory' do
      allow(Dir).to receive(:glob)
        .with([
          "#{Hackney::PDF::GetTemplates::LEASEHOLD_SERVICES_TEMPLATE_DIRECTORY_PATH}*.erb",
          "#{Hackney::PDF::GetTemplates::INCOME_COLLECTION_TEMPLATE_DIRECTORY_PATH}*.erb"
        ])
        .and_return([test_template[:path]])

      expect(subject.execute(
               user_groups: [
                 Hackney::PDF::GetTemplates::INCOME_COLLECTION_GROUP,
                 Hackney::PDF::GetTemplates::LEASEHOLD_SERVICES_GROUP
               ]
             )).to eq([test_template])
    end
  end

  context 'when user is not in any appropriate group' do
    it 'no templates are found' do
      expect(subject.execute(user_groups: ['muffins'])).to eq([])
    end
  end
end
