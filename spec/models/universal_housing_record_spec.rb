require 'rails_helper'

describe UniversalHousingRecord do
  it 'should provide a connection to Universal Housing' do
    expect(ExampleUniversalHousingModel).to be_connected
  end

  it 'should be read only' do
    expect {
      ExampleUniversalHousingModel.create(tag_ref: '999999/FAKE')
    }.to raise_error(ActiveRecord::ReadOnlyRecord)
  end

  class ExampleUniversalHousingModel < described_class
    self.table_name = :arag
  end
end
