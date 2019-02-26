class PdfController < ApplicationController
  def get_templates
    render json: pfd_use_case_factory.get_templates.execute
  end
end
