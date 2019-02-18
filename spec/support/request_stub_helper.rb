require 'webmock/rspec'

module RequestStubHelper
  def request_stub(options = {})
    method = options.fetch(:method, :get)
    url = options.fetch(:url, 'https://example.com')
    request_headers = options.fetch(:request_headers, default_headers)
    response_headers = options.fetch(:response_headers, {})
    response_status = options.fetch(:response_status, 200)
    response_body = options.fetch(:response_body, '{}')

    stub_request(method, url).with(headers: request_headers).to_return(status: response_status, body: response_body, headers: response_headers)
  end

  private

  def default_headers
    {
      'Accept' => 'application/json',
      'Content-Type' => 'application/json',
      'X-Api-Key' => 'skeleton'
    }
  end
end
