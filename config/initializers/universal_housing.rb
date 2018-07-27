UNIVERSAL_HOUSING_CONFIG = YAML.load(ERB.new(File.read(Rails.root.join('config', 'database_universal_housing.yml'))).result)[Rails.env.to_s]
