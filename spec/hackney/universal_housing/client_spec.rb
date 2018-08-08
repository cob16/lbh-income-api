require 'rails_helper'

describe Hackney::UniversalHousing::Client do
  subject { described_class.connection }

  it 'to be a Sequel database instance' do
    expect(subject).to be_a(Sequel::TinyTDS::Database)
  end

  it 'can execute queries against the database' do
    expect(subject.table_exists?('tenagree')).to be(true)
  end
end
