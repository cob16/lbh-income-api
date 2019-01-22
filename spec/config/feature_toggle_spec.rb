require_relative '../../config/feature_toggle'

describe FeatureToggle do
  subject do
    dummy_class = Class.new
    dummy_class.extend(described_class)
    dummy_class
  end

  let(:env_var_name) { 'FEATURE_TOGGLE_TEST' }
  let(:env_var_value) { 'TRUE' }

  before do
    ENV[env_var_name] = env_var_value
  end

  after do
    ENV[env_var_name] = nil
  end

  it 'is true when set true' do
    expect(subject.feature_toggle(env_var_name)).to eq(true)
  end

  context 'when uppercase' do
    let(:env_var_value) { 'TRUE' }

    it 'returns false' do
      expect(subject.feature_toggle(env_var_name)).to eq(true)
    end
  end

  context 'when uppercase' do
    let(:env_var_value) { 'FALSE' }

    it 'returns false' do
      expect(subject.feature_toggle(env_var_name)).to eq(false)
    end
  end

  context 'when title case' do
    let(:env_var_value) { 'False' }

    it 'returns false' do
      expect(subject.feature_toggle(env_var_name)).to eq(false)
    end
  end

  context 'when not provided' do
    it 'returns false' do
      expect(subject.feature_toggle('random_var_name_why_would_you_set_me')).to eq(false)
    end
  end

  context 'when empty string' do
    let(:env_var_value) { '' }

    it 'returns false' do
      expect(subject.feature_toggle('random_var_name_why_would_you_set_me')).to eq(false)
    end
  end
end
