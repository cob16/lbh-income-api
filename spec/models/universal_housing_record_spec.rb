require 'rails_helper'

describe UniversalHousingRecord do
  it 'should provide a connection to Universal Housing' do
    expect(ExampleUniversalHousingModel).to be_connected
  end

  it 'should not be read only in test' do
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('test'))

    expect {
      ExampleUniversalHousingModel.create(tag_ref: '999999/FAKE')
    }.to_not raise_error
  end

  it 'should be read only otherwise' do
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('scary'))

    expect {
      ExampleUniversalHousingModel.create(tag_ref: '999999/FAKE')
    }.to raise_error(ActiveRecord::ReadOnlyRecord)
  end

  class ExampleUniversalHousingModel < described_class
    self.table_name = :arag
  end
end
