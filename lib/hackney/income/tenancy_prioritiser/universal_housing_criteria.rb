module Hackney
  module Income
    class TenancyPrioritiser
      class UniversalHousingCriteria
        def self.for_tenancy(universal_housing_client, tenancy_ref)
          sql = <<-SQL
            DECLARE @TenancyRef VARCHAR(60) = '#{tenancy_ref}'
            DECLARE @ActiveArrearsAgreementStatus VARCHAR(60) = '#{ACTIVE_ARREARS_AGREEMENT_STATUS}'
            DECLARE @BreachedArrearsAgreementStatus VARCHAR(60) = '#{BREACHED_ARREARS_AGREEMENT_STATUS}'
            DECLARE @NospActionDiaryCode VARCHAR(60) = '#{NOSP_ACTION_DIARY_CODE}'

            DECLARE @PaymentTypes table(payment_type varchar(3))
            INSERT INTO @PaymentTypes VALUES ('RBA'), ('RBP'), ('RBR'), ('RCI'), ('RCO'), ('RCP'), ('RDD'), ('RDN'), ('RDP'), ('RDR'), ('RDS'), ('RDT'), ('REF'), ('RHA'), ('RHB'), ('RIT'), ('RML'), ('RPD'), ('RPO'), ('RPY'), ('RQP'), ('RRC'), ('RRP'), ('RSO'), ('RTM'), ('RUC'), ('RWA')
            DECLARE @CurrentBalance numeric(9, 2) = (SELECT cur_bal FROM [dbo].[tenagree] WHERE tag_ref = @TenancyRef)
            DECLARE @LastPaymentDate SMALLDATETIME = (
              SELECT post_date FROM (
                SELECT ROW_NUMBER() OVER (ORDER BY post_date DESC) AS row, post_date
                FROM [dbo].[rtrans]
                WHERE tag_ref = @TenancyRef
                AND trans_type IN (SELECT payment_type FROM @PaymentTypes)
              ) t
              WHERE row = 1
            )
            DECLARE @RemainingTransactions INT = (SELECT COUNT(*) FROM [dbo].[rtrans] WHERE tag_ref = @TenancyRef)
            DECLARE @ActiveAgreementsCount INT = (SELECT COUNT(*) FROM [dbo].[arag] WHERE tag_ref = @TenancyRef AND arag_status = @ActiveArrearsAgreementStatus)
            DECLARE @BreachedAgreementsCount INT = (SELECT COUNT(*) FROM [dbo].[arag] WHERE tag_ref = @TenancyRef AND arag_status = @BreachedArrearsAgreementStatus)
            DECLARE @NospsInLastYear INT = (SELECT COUNT(*) FROM araction WHERE tag_ref = @TenancyRef AND action_code = @NospActionDiaryCode AND action_date >= CONVERT(date, DATEADD(year, -1, GETDATE())))
            DECLARE @NospsInLastMonth INT = (SELECT COUNT(*) FROM araction WHERE tag_ref = @TenancyRef AND action_code = @NospActionDiaryCode AND action_date >= CONVERT(date, DATEADD(month, -1, GETDATE())))
            DECLARE @NextBalance numeric(9, 2) = @CurrentBalance
            DECLARE @CurrentTransactionRow INT = 1
            DECLARE @LastTransactionDate SMALLDATETIME = GETDATE()
            WHILE (@NextBalance > 0 AND @RemainingTransactions > 0)
            BEGIN
              SELECT @NextBalance = @NextBalance - real_value, @LastTransactionDate = post_date
              FROM (
                SELECT ROW_NUMBER() OVER (ORDER BY post_date DESC) as row, real_value, post_date
                FROM rtrans
                WHERE tag_ref = @TenancyRef
              ) t
              WHERE row = @CurrentTransactionRow

              SET @RemainingTransactions = @RemainingTransactions - 1
              SET @CurrentTransactionRow = @CurrentTransactionRow + 1
            END

            DECLARE @Payment1Value numeric(9, 2) = (SELECT real_value FROM (SELECT ROW_NUMBER() OVER(ORDER BY post_date DESC) as row, real_value FROM rtrans WHERE tag_ref = @TenancyRef AND trans_type IN (SELECT * FROM @PaymentTypes)) t WHERE row = 1)
            DECLARE @Payment1Date SMALLDATETIME = (SELECT post_date FROM (SELECT ROW_NUMBER() OVER(ORDER BY post_date DESC) as row, post_date FROM rtrans WHERE tag_ref = @TenancyRef AND trans_type IN (SELECT * FROM @PaymentTypes)) t WHERE row = 1)
            DECLARE @Payment2Value numeric(9, 2) = (SELECT real_value FROM (SELECT ROW_NUMBER() OVER(ORDER BY post_date DESC) as row, real_value FROM rtrans WHERE tag_ref = @TenancyRef AND trans_type IN (SELECT * FROM @PaymentTypes)) t WHERE row = 2)
            DECLARE @Payment2Date SMALLDATETIME = (SELECT post_date FROM (SELECT ROW_NUMBER() OVER(ORDER BY post_date DESC) as row, post_date FROM rtrans WHERE tag_ref = @TenancyRef AND trans_type IN (SELECT * FROM @PaymentTypes)) t WHERE row = 2)
            DECLARE @Payment3Value numeric(9, 2) = (SELECT real_value FROM (SELECT ROW_NUMBER() OVER(ORDER BY post_date DESC) as row, real_value FROM rtrans WHERE tag_ref = @TenancyRef AND trans_type IN (SELECT * FROM @PaymentTypes)) t WHERE row = 3)
            DECLARE @Payment3Date SMALLDATETIME = (SELECT post_date FROM (SELECT ROW_NUMBER() OVER(ORDER BY post_date DESC) as row, post_date FROM rtrans WHERE tag_ref = @TenancyRef AND trans_type IN (SELECT * FROM @PaymentTypes)) t WHERE row = 3)

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
          SQL

          query = universal_housing_client.execute(sql)
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
