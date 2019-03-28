class LettersController < ApplicationController
  LETTER_FILE_NAME = 'letter.pdf'.freeze

  def download
    response = letter_use_case_factory.download.execute(id: params.fetch(:id))

    send_data response[:content], filename: LETTER_FILE_NAME
  end
end
