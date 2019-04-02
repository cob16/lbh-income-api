module Hackney
  module Letter
    class UseCaseFactory
      def download
        Hackney::Letter::DownloadUseCase.new(
          Hackney::Cloud::Storage.new(Rails.configuration.cloud_adapter, Hackney::Cloud::Document)
        )
      end
    end
  end
end
