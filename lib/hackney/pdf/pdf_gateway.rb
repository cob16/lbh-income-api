require 'pdfkit'

module Hackney
  module PDF
    class PDFGateway
      def initialize; end

      def generate_pdf(html)
        kit = PDFKit.new(html, pdf_options)
        kit.stylesheets << 'lib/hackney/pdf/templates/pdf_styles.css'
        kit
      end

      private

      def pdf_options
        {
          disable_smart_shrinking: false,
          page_size: 'A4',
          margin_top: '0.19685in',
          margin_right: '0.590551in',
          margin_bottom: '0.19685in',
          margin_left: '0.590551in'
        }
      end
    end
  end
end
