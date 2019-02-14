require 'webmock/rspec'

module RequestStubHelper
  def request_stub(options = {})
    url = options.fetch(:url, 'https://example.com')
    status = options.fetch(:status, 200)
    method = options.fetch(:method, :get)
    response_body = options.fetch(:response_body, '{}')

    stub_request(method, url).with(
      headers: { 'x-api-key' => 'skeleton' }
    ).to_return(status: status, body: response_body)
  end
end
