require_relative '../../config/feature_toggle'

describe FeatureToggle do
  let(:env_var_name) { 'FEATURE_TOGGLE_TEST' }
  let(:env_var_value) { 'TRUE' }

  subject do
    dummy_class = Class.new
    dummy_class.extend(FeatureToggle)
    dummy_class
  end

  before do
    ENV[env_var_name] = env_var_value
  end

  it 'should be true when set true' do
    expect(subject.feature_toggle(env_var_name)).to eq(true)
  end

  context 'when uppercase' do
    let(:env_var_value) { 'TRUE' }

    it 'should return false' do
      expect(subject.feature_toggle(env_var_name)).to eq(true)
    end
  end

  context 'when uppercase' do
    let(:env_var_value) { 'FALSE' }

    it 'should return false' do
      expect(subject.feature_toggle(env_var_name)).to eq(false)
    end
  end

  context 'when title case' do
    let(:env_var_value) { 'False' }

    it 'should return false' do
      expect(subject.feature_toggle(env_var_name)).to eq(false)
    end
  end

  context 'when not provided' do
    it 'should return false' do
      expect(subject.feature_toggle('random_var_name_why_would_you_set_me')).to eq(false)
    end
  end

  context 'when empty string' do
    let(:env_var_value) { '' }

    it 'should return false' do
      expect(subject.feature_toggle('random_var_name_why_would_you_set_me')).to eq(false)
    end
  end

  after do
    ENV[env_var_name] = nil
  end
end
