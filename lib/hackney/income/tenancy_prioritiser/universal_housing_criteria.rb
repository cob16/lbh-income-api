module Hackney
  module Income
    class TenancyPrioritiser
      class UniversalHousingCriteria
        def self.for_tenancy(tenancy_ref)
          new(tenancy_ref)
        end

        def initialize(tenancy_ref)
          @tenancy_ref = tenancy_ref
        end

        def balance
          Hackney::UniversalHousing::Models::Tenagree.find_by(tag_ref: tenancy_ref).cur_bal.to_f
        end

        def days_in_arrears
          current_balance = Hackney::UniversalHousing::Models::Tenagree.find_by(tag_ref: tenancy_ref).cur_bal.to_f
          return 0 if credit_balance?(current_balance)

          transactions = Hackney::UniversalHousing::Models::Rtrans.order(post_date: :desc).where(tag_ref: tenancy_ref)

          next_balance = current_balance
          transactions.each do |transaction|
            next_balance = next_balance - transaction.real_value
            return day_difference(Date.today, transaction.post_date) if credit_balance?(next_balance)
          end

          day_difference(Date.today, transactions.last.post_date)
        end

        def days_since_last_payment
          last_payment = Hackney::UniversalHousing::Models::Rtrans.order(post_date: :desc).where(tag_ref: tenancy_ref, trans_type: PAYMENT_TRANSACTION_TYPE).first
          return nil if last_payment.nil?

          day_difference(Date.today, last_payment.post_date)
        end

        def active_agreement?
          Hackney::UniversalHousing::Models::Arag.where(tag_ref: tenancy_ref, arag_status: ACTIVE_ARREARS_AGREEMENT_STATUS).any?
        end

        private

        PAYMENT_TRANSACTION_TYPE = 'RPY'.freeze
        private_constant :PAYMENT_TRANSACTION_TYPE

        ACTIVE_ARREARS_AGREEMENT_STATUS = '200'.freeze
        private_constant :ACTIVE_ARREARS_AGREEMENT_STATUS

        attr_reader :tenancy_ref

        def credit_balance?(balance)
          balance <= 0
        end

        def day_difference(date_a, date_b)
          (date_a.to_date - date_b.to_date).to_i
        end
      end
    end
  end
end
