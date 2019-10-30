require 'rails_helper'

describe UseCases::SaveLetterToCloud do
  subject { described_class.new(cloud_gateway: double) }

  it 'works' do
    subject.execute(nil)
  end
end
