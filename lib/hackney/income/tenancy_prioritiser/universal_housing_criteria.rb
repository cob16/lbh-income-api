module Hackney
  module Income
    class TenancyPrioritiser
      class UniversalHousingCriteria
        def self.sql_client
          TinyTds::Client.new(
            username: ENV['UH_DATABASE_USERNAME'],
            password: ENV['UH_DATABASE_PASSWORD'],
            host: ENV['UH_DATABASE_HOST'],
            port: ENV['UH_DATABASE_PORT'],
            database: ENV['UH_DATABASE_NAME']
          )
        end

        def self.for_tenancy(tenancy_ref)
          query = sql_client.execute("
            DECLARE @CurrentBalance numeric(9, 2) = (SELECT cur_bal FROM [dbo].[tenagree] WHERE tag_ref = '#{tenancy_ref}')
            DECLARE @LastPaymentDate SMALLDATETIME = (SELECT post_date FROM [dbo].[rtrans] WHERE tag_ref = '#{tenancy_ref}' AND trans_type = '#{PAYMENT_TRANSACTION_TYPE}' ORDER BY post_date DESC OFFSET 0 ROWS FETCH NEXT 1 ROW ONLY)
            DECLARE @RemainingTransactions INT = (SELECT COUNT(*) FROM [dbo].[rtrans] WHERE tag_ref = '#{tenancy_ref}')
            DECLARE @ActiveAgreementsCount INT = (SELECT COUNT(*) FROM [dbo].[arag] WHERE tag_ref = '#{tenancy_ref}' AND arag_status = '#{ACTIVE_ARREARS_AGREEMENT_STATUS}')
            DECLARE @BreachedAgreementsCount INT = (SELECT COUNT(*) FROM [dbo].[arag] WHERE tag_ref = '#{tenancy_ref}' AND arag_status = '#{BREACHED_ARREARS_AGREEMENT_STATUS}')
            DECLARE @NospsInLastYear INT = (SELECT COUNT(*) FROM araction WHERE tag_ref = '#{tenancy_ref}' AND action_code = '#{NOSP_ACTION_DIARY_CODE}' AND action_date >= CONVERT(date, DATEADD(year, -1, GETDATE())))
            DECLARE @NospsInLastMonth INT = (SELECT COUNT(*) FROM araction WHERE tag_ref = '#{tenancy_ref}' AND action_code = '#{NOSP_ACTION_DIARY_CODE}' AND action_date >= CONVERT(date, DATEADD(month, -1, GETDATE())))
            DECLARE @NextBalance numeric(9, 2) = @CurrentBalance
            DECLARE @Offset INT = 0
            DECLARE @LastTransactionDate SMALLDATETIME = GETDATE()
            WHILE (@NextBalance > 0 AND @RemainingTransactions > 0)
            BEGIN
              SELECT @NextBalance = @NextBalance - real_value, @LastTransactionDate = post_date
              FROM rtrans WHERE tag_ref = '#{tenancy_ref}' ORDER BY post_date DESC OFFSET @Offset ROWS FETCH NEXT 1 ROW ONLY

              SET @RemainingTransactions = @RemainingTransactions - 1
              SET @Offset = @Offset + 1
            END

            DECLARE @Payment1Value numeric(9, 2) = (SELECT real_value FROM rtrans WHERE trans_type = '#{PAYMENT_TRANSACTION_TYPE}' ORDER BY post_date DESC OFFSET 0 ROWS FETCH NEXT 1 ROW ONLY)
            DECLARE @Payment1Date SMALLDATETIME = (SELECT post_date FROM rtrans WHERE trans_type = '#{PAYMENT_TRANSACTION_TYPE}' ORDER BY post_date DESC OFFSET 0 ROWS FETCH NEXT 1 ROW ONLY)
            DECLARE @Payment2Value numeric(9, 2) = (SELECT real_value FROM rtrans WHERE trans_type = '#{PAYMENT_TRANSACTION_TYPE}' ORDER BY post_date DESC OFFSET 1 ROWS FETCH NEXT 1 ROW ONLY)
            DECLARE @Payment2Date SMALLDATETIME = (SELECT post_date FROM rtrans WHERE trans_type = '#{PAYMENT_TRANSACTION_TYPE}' ORDER BY post_date DESC OFFSET 1 ROWS FETCH NEXT 1 ROW ONLY)
            DECLARE @Payment3Value numeric(9, 2) = (SELECT real_value FROM rtrans WHERE trans_type = '#{PAYMENT_TRANSACTION_TYPE}' ORDER BY post_date DESC OFFSET 2 ROWS FETCH NEXT 1 ROW ONLY)
            DECLARE @Payment3Date SMALLDATETIME = (SELECT post_date FROM rtrans WHERE trans_type = '#{PAYMENT_TRANSACTION_TYPE}' ORDER BY post_date DESC OFFSET 2 ROWS FETCH NEXT 1 ROW ONLY)

            SELECT
              @CurrentBalance as current_balance,
              @LastPaymentDate as last_payment_date,
              @LastTransactionDate as pre_arrears_date,
              @ActiveAgreementsCount as active_agreements_count,
              @BreachedAgreementsCount as breached_agreements_count,
              @NospsInLastYear as nosps_in_last_year,
              @NospsInLastMonth as nosps_in_last_month,
              @Payment1Value as payment_1_value,
              @Payment1Date as payment_1_date,
              @Payment2Value as payment_2_value,
              @Payment2Date as payment_2_date,
              @Payment3Value as payment_3_value,
              @Payment3Date as payment_3_date;
          ")
          attributes = query.each(first: true).first
          query.do

          new(tenancy_ref, attributes.symbolize_keys)
        end

        def initialize(tenancy_ref, attributes)
          @tenancy_ref = tenancy_ref
          @attributes = attributes
        end

        def balance
          attributes.fetch(:current_balance).to_f
        end

        def days_in_arrears
          day_difference(Date.today, attributes.fetch(:pre_arrears_date))
        end

        def days_since_last_payment
          return nil if attributes.fetch(:last_payment_date).nil?
          day_difference(Date.today, attributes.fetch(:last_payment_date))
        end

        def active_agreement?
          attributes.fetch(:active_agreements_count) > 0
        end

        def number_of_broken_agreements
          attributes.fetch(:breached_agreements_count)
        end

        def nosp_served?
          attributes.fetch(:nosps_in_last_year) > 0
        end

        def active_nosp?
          attributes.fetch(:nosps_in_last_month) > 0
        end

        def payment_amount_delta
          payment_amounts = [
            attributes.fetch(:payment_1_value),
            attributes.fetch(:payment_2_value),
            attributes.fetch(:payment_3_value)
          ].compact.map(&:to_f)

          return nil if payment_amounts.count < 3

          (payment_amounts[0] - payment_amounts[1]) - (payment_amounts[1] - payment_amounts[2])
        end

        def payment_date_delta
          payment_dates = [
            attributes.fetch(:payment_1_date),
            attributes.fetch(:payment_2_date),
            attributes.fetch(:payment_3_date)
          ].compact

          return nil if payment_dates.count < 3

          day_difference(payment_dates[0], payment_dates[1]) - day_difference(payment_dates[1], payment_dates[2])
        end

        # FIXME: implementation needs confirming, will return to later
        def broken_court_order?
          false
        end

        private

        PAYMENT_TRANSACTION_TYPE = 'RPY'.freeze
        private_constant :PAYMENT_TRANSACTION_TYPE

        ACTIVE_ARREARS_AGREEMENT_STATUS = '200'.freeze
        private_constant :ACTIVE_ARREARS_AGREEMENT_STATUS

        BREACHED_ARREARS_AGREEMENT_STATUS = '300'.freeze
        private_constant :BREACHED_ARREARS_AGREEMENT_STATUS

        NOSP_ACTION_DIARY_CODE = 'NTS'.freeze
        private_constant :NOSP_ACTION_DIARY_CODE

        attr_reader :tenancy_ref, :attributes

        def day_difference(date_a, date_b)
          (date_a.to_date - date_b.to_date).to_i
        end
      end
    end
  end
end
