module Hackney
  module Income
    class TenancyPrioritiser
      AMBER_SCORE_THRESHOLD = 150
      RED_SCORE_THRESHOLD = 500

      def initialize(criteria:, weightings:)
        @criteria = criteria
        @weightings = weightings
      end

      def priority_score
        score_assigner.execute
      end

      def priority_band
        computed_priority_band.tap do |band|
          return :green if band == :green && @criteria.active_agreement?
          return :amber if band == :green && priority_score > AMBER_SCORE_THRESHOLD
          return :red if band == :amber && priority_score > RED_SCORE_THRESHOLD
        end
      end

      private

      def computed_priority_band
        band_assigner.execute
      end

      def score_assigner
        Hackney::Income::TenancyPrioritiser::Score.new(@criteria, @weightings)
      end

      def band_assigner
        Hackney::Income::TenancyPrioritiser::Band.new(@criteria)
      end
    end
  end
end
