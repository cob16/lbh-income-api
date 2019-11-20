module Hackney
  module PDF
    class IncomePreviewGenerator
      LOGO_PATH = 'lib/hackney/pdf/templates/layouts/logo.svg'.freeze

      def initialize(template_path:)
        @template_path = template_path
        @errors = []
        @today_date = get_sending_date
        @logo = File.open(LOGO_PATH).read
      end

      def execute(letter_params:, username:)
        @letter = Hackney::IncomeCollection::Letter.build(letter_params: letter_params, template_path: @template_path)
        @username = username
        template = File.open(@template_path).read
        html = ERB.new(template).result(binding)

        {
          html: html,
          errors: @letter.errors
        }
      end

      private

      def get_date
        (Time.now + 1.day).strftime('%d %B %Y')
      end

      def get_return_date
        30.days.from_now.strftime('%d %B %Y')
      end

      def get_sending_date
        Time.now.strftime('%d %B %Y')
      end
    end
  end
end
