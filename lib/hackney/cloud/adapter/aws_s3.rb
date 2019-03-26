module Hackney
  module Cloud
    module Adapter
      class AwsS3
        def initialize(encryption_client)
          @client = encryption_client
        end

        def upload(bucket_name:, content:, filename:)
          # Add encrypted item to bucket
          response = client.put_object(
            body: content,
            bucket: bucket_name,
            key: filename
          )

          parse_response_context(response)
        end

        def download(bucket_name:, filename:)
          client.get_object(bucket: bucket_name, key: filename)
        end

        private

        attr_reader :client

        def parse_response_context(response)
          http_request_context = response.context.http_request

          uploaded_at = Time.parse(http_request_context.headers['x-amz-date'])

          url = http_request_context.endpoint
          { url: url, uploaded_at: uploaded_at }
        end

        def customer_managed_key
          Rails.application.config_for('cloud_storage')['customer_managed_key']
        end
      end
    end
  end
end
