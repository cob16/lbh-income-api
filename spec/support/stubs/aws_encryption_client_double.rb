class AwsEncryptionClientDouble
  def initialize(blah); end

  def put_object(*)
    context
  end

  def context
    OpenStruct.new(
      context: OpenStruct.new(
        http_request: OpenStruct.new(headers: { 'x-amz-date' => Time.new(2002).to_s }, endpoint: 'blah.com')
      )
    )
  end
end
