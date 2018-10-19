require 'active_model'
require 'active_model/type/value'
require 'active_model/type/boolean'

module FeatureToggle
  def feature_toggle(name)
    ActiveModel::Type::Boolean.new.cast(
      ENV.fetch(name, false).to_s.downcase
    )
  end
end
