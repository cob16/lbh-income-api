module Hackney
  module Cloud
    module Adapter
      class Fake
        def upload(bucket_name:, content:, filename:)
          "https://#{bucket_name}/#{filename}"
        end
      end
    end
  end
end
