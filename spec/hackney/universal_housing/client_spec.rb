require 'rails_helper'

describe Hackney::UniversalHousing::Client do
  subject { described_class.connection }

  it 'connects using environmental configuration' do
    expect(subject).to be_active
  end

  it 'to be a TinyTds instance' do
    expect(subject).to be_a(TinyTds::Client)
  end
end
