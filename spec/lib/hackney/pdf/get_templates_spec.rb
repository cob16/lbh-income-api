require 'rails_helper'

describe Hackney::PDF::GetTemplates do
  subject do
    described_class.new(
      template_directory_path: 'spec/lib/hackney/pdf/'
    )
  end

  it 'finds the templates are found' do
    expect(subject.execute).to eq([
      {
        id: 'test_template_1', name: 'Test template 1', path: 'spec/lib/hackney/pdf/test_template_1.erb'
      },
      {
        id: 'test_template_2', name: 'Test template 2', path: 'spec/lib/hackney/pdf/test_template_2.erb'
      }
    ])
  end
end
