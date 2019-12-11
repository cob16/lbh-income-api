module UseCases
  class CaseClassificationToLetterTypeMap
    def execute(case_priority:)
      return 'income_collection_letter_1' if send_letter_one?(case_priority)

      return 'income_collection_letter_2' if send_letter_two?(case_priority)
    end

    private

    def send_letter_one?(case_priority)
      env_allowed_to_send_letter_one? && case_priority.send_letter_one?
    end

    def send_letter_two?(case_priority)
      env_allowed_to_send_letter_two? && case_priority.send_letter_two?
    end

    def env_allowed_to_send_letter_one?
      App::Application.feature_toggle('AUTOMATE_INCOME_COLLECTION_LETTER_ONE')
    end

    def env_allowed_to_send_letter_two?
      App::Application.feature_toggle('AUTOMATE_INCOME_COLLECTION_LETTER_TWO')
    end
  end
end
