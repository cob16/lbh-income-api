require 'rails_helper'

describe Hackney::PDF::GetTemplates do
  subject do
    described_class.new(
      template_directory_path: 'spec/lib/hackney/pdf/'
    )
  end

  it 'the templates are found' do
    expect(subject.execute).to eq([{
      id: 'test_template', name: 'Test template', path: 'spec/lib/hackney/pdf/test_template.erb'
    }])
  end
end
