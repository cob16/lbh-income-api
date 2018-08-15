module Hackney
  module Income
    class HardcodedTenanciesUndefinedError < RuntimeError; end

    class HardcodedTenanciesGateway
      def tenancies_in_arrears
        ENV.fetch('HARDCODED_TENANCIES').split(',')
      rescue KeyError
        raise HardcodedTenanciesUndefinedError.new
      end
    end
  end
end
