require 'rails_helper'

describe Hackney::PDF::GetTemplates do
  subject do
    described_class.new()
  end

  let(:test_template_path) { 'spec/lib/hackney/pdf/test_template.erb' }

  context 'finding leasehold templates' do

    it 'templates are found in the correct directory' do
      allow(Dir).to receive(:glob)
                      .with("#{Hackney::PDF::GetTemplates::LEASEHOLD_SERVICES_TEMPLATE_DIRECTORY_PATH}*.erb")
                      .and_return([test_template_path])

      expect(subject.execute(user_groups: [Hackney::PDF::GetTemplates::LEASEHOLD_SERVICES_GROUP]))
        .to eq([{
                  id: 'test_template', name: 'Test template', path: test_template_path
                }])
    end
  end

  context 'finding income templates' do

    it 'templates are found in the correct directory' do
      allow(Dir).to receive(:glob)
                      .with("#{Hackney::PDF::GetTemplates::INCOME_COLLECTION_TEMPLATE_DIRECTORY_PATH}*.erb")
                      .and_return([test_template_path])

      expect(subject.execute(user_groups: [Hackney::PDF::GetTemplates::INCOME_COLLECTION_GROUP]))
        .to eq([{
                  id: 'test_template', name: 'Test template', path: test_template_path
                }])
    end
  end
end
