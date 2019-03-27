module Hackney
  module Cloud
    module Adapter
      class Fake
        @cloud_storage = {}

        def upload(bucket_name:, filename:, new_filename:)
          Fake.save(new_filename, File.read(filename))
        end

        def download(bucket_name, filename)
          Fake.read(filename)
        end

        def self.save(key, value)
          @cloud_storage[key] = value
        end

        def self.read(key)
          @cloud_storage[key]
        end
      end
    end
  end
end
