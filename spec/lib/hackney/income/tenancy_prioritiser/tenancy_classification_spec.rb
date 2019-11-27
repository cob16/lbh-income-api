require 'rails_helper'

describe Hackney::Income::TenancyPrioritiser::TenancyClassification do
  subject { assign_classification.execute }

  let(:criteria) { Stubs::StubCriteria.new(attributes) }
  let(:assign_classification) { described_class.new(case_priority, criteria) }

  let(:attributes) do
    {
      weekly_rent: weekly_rent,
      balance: balance,
      nosp_served: nosp_served,
      last_communication_date: last_communication_date,
      last_communication_action: last_communication_action,
      active_agreement: active_agreement,
      nosp_expiry_date: nosp_expiry_date,
      nosps_in_last_year: nosps_in_last_year,
      nosp_served_date: nosp_served_date,
      courtdate: courtdate
    }
  end

  let(:case_priority) { build(:case_priority, is_paused_until: is_paused_until) }
  let(:is_paused_until) { nil }
  let(:weekly_rent) { 5.0 }
  let(:balance) { 5.00 }
  let(:nosp_served) { false }
  let(:nosp_expiry_date) { '' }
  let(:last_communication_date) { 8.days.ago.to_date }
  let(:last_communication_action) { nil }
  let(:nosp_served_date) { nil }
  let(:active_agreement) { nil }
  let(:nosps_in_last_year) { nil }
  let(:courtdate) { nil }

  context 'when there are no arrears' do
    context 'with difference balances' do
      balances = {
        in_credit: -3.00,
        under_five_pounds: 4.00,
        just_under_five_pounds: 4.99
      }

      balances.each do |key, balance|
        let(:balance) { balance }

        it "can classify a no action tenancy when the arrear level is #{key}" do
          expect(subject).to eq(:no_action)
        end
      end
    end

    context 'when the last action taken was over three months ago' do
      let(:last_communication_date) { 3.months.ago.to_date - 1.day }

      it 'can classify a no action tenancy' do
        expect(subject).to eq(:no_action)
      end
    end

    context 'when the last communication date was less than a week ago' do
      let(:last_communication_date) { 6.days.ago.to_date }

      it 'can classify a no action tenancy ' do
        expect(subject).to eq(:no_action)
      end
    end

    context 'when the the case has been paused' do
      let(:balance) { 15.00 }
      let(:nosp_served) { false }
      let(:last_communication_date) { 6.days.ago.to_date }
      let(:is_paused_until) { 7.days.from_now }

      it 'can classify a no action tenancy' do
        expect(subject).to eq(:no_action)
      end
    end

    context 'when a NOSP has been served' do
      let(:nosp_served) { true }

      it 'can classify a no action tenancy ' do
        expect(subject).to eq(:no_action)
      end
    end
  end

  context 'when no nosps have been served and the cases are not paused' do
    let(:nosp_served) { false }

    context 'when arrears level is greater than or equal to £5 and less than £10' do
      context 'with different balances' do
        balances = {
          five_pounds: 5.00,
          just_over_five_pounds: 5.01,
          over_five_pounds: 6.00,
          just_under_ten_pounds: 9.99
        }

        balances.each do |key, balance|
          let(:balance) { balance }

          it "can classify a send SMS tenancy when the arrear level is #{key}" do
            expect(subject).to eq(:send_first_SMS)
          end
        end
      end

      context 'with different last_communication_dates' do
        last_communication_dates = {
          seven_days_ago: 7.days.ago.to_date,
          eight_days_ago: 8.days.ago.to_date,
          within_three_months: 3.months.ago.to_date
        }

        last_communication_dates.each do |key, last_communication_date|
          let(:last_communication_date) { last_communication_date }

          it "can classify a send SMS tenancy when the last communication date is #{key}" do
            expect(subject).to eq(:send_first_SMS)
          end
        end
      end
    end

    context 'when the arrears are greater than or equal to £10 and less than one week rent' do
      context 'with different last communication actions' do
        last_communication_actions = {
          green_SMS_sent_auto: 'GAT',
          green_SMS_sent_manual: 'GMS'
        }

        let(:balance) { 11.00 }

        last_communication_actions.each do |key, last_communication_action|
          let(:last_communication_action) { last_communication_action }

          it "can classify to send letter one when arrears are more than £10 with a last communication action of #{key} " do
            expect(subject).to eq(:send_letter_one)
          end
        end
      end
    end

    context 'when the arrears are greater than or equal to one weeks rent and less than 3 week rent' do
      context 'with different last_communication_actions' do
        let(:balance) { weekly_rent }

        last_communication_actions = {
          letter_one_in_arrears_auto: 'ZR1'
        }

        last_communication_actions.each do |key, last_communication_action|
          let(:last_communication_action) { last_communication_action }

          context "when the tenant has arreas of 1 week with a last communication action of #{key}" do
            it 'can classify to send letter two' do
              expect(subject).to eq(:send_letter_two)
            end
          end

          context "when the tenant is over 1 weeks in arrears with a last communication action of #{key}" do
            let(:last_communication_date) { 8.days.ago.to_date + 1.day }

            it 'can classify to send letter two' do
              expect(subject).to eq(:send_letter_two)
            end
          end

          context "when the tenant has just under 3 weeks with a last communication action of #{key}" do
            let(:balance) { weekly_rent * 3 - 1 }

            it 'can classify to send letter two' do
              expect(subject).to eq(:send_letter_two)
            end
          end
        end
      end
    end

    context 'when the arrears are greater than or equal to three weeks rent and less than 4 week rent' do
      last_communication_actions = {
        letter_two_in_arrears: 'ZR2'
      }

      last_communication_actions.each do |key, last_communication_action|
        let(:last_communication_action) { last_communication_action }

        context "when the tenant has missed three weeks rent with a last communication action of #{key}" do
          let(:balance) { weekly_rent * 3 }

          it 'can classify to send a warning letter' do
            expect(subject).to eq(:send_warning_letter)
          end
        end

        context "when the tenant has missed just under 4 weeks rent with a last communication action of #{key}" do
          let(:balance) { weekly_rent * 4 - 1 }

          it 'can classify to send a warning letter' do
            expect(subject).to eq(:send_warning_letter)
          end
        end
      end
    end
  end

  context 'when testing `send_NOSP`' do
    pre_nosp_warning_letter = 'IC3'
    condition_matrix = [
      {
        outcome: :no_action,
        nosps_in_last_year: 1,
        nosp_expiry_date: 8.months.from_now.to_date,
        weekly_rent: 5,
        balance: 25.0, # 5 * weekly_rent
        is_paused_until: nil,
        active_agreement: false,
        last_communication_date: 2.months.ago.to_date,
        last_communication_action: pre_nosp_warning_letter
      },
      {
        outcome: :no_action,
        nosps_in_last_year: 0,
        nosp_expiry_date: 1.month.ago.to_date,
        weekly_rent: 5,
        balance: 10.0, # 2 * weekly_rent
        is_paused_until: nil,
        active_agreement: false,
        last_communication_date: 2.months.ago.to_date,
        last_communication_action: pre_nosp_warning_letter
      },
      {
        outcome: :no_action,
        nosps_in_last_year: 0,
        nosp_expiry_date: 1.month.ago.to_date,
        weekly_rent: 5,
        balance: 25.0, # 5 * weekly_rent
        is_paused_until: 1.month.from_now,
        active_agreement: false,
        last_communication_date: 2.months.ago.to_date,
        last_communication_action: pre_nosp_warning_letter
      },
      {
        outcome: :send_warning_letter,
        nosps_in_last_year: 0,
        nosp_expiry_date: '',
        weekly_rent: 5,
        balance: 25.0, # 5 * weekly_rent
        is_paused_until: nil,
        active_agreement: false,
        last_communication_date: 2.months.ago.to_date,
        last_communication_action: 'ZR2' # Stage 02 Complete / Letter 2 Sent
      },
      {
        outcome: :no_action,
        nosps_in_last_year: 0,
        nosp_expiry_date: '',
        weekly_rent: 5,
        balance: 25.0, # 5 * weekly_rent
        is_paused_until: nil,
        active_agreement: false,
        last_communication_date: 5.days.ago.to_date,
        last_communication_action: pre_nosp_warning_letter
      },
      {
        outcome: :send_NOSP,
        nosps_in_last_year: 0,
        nosp_expiry_date: '',
        weekly_rent: 5,
        balance: 25.0, # 5 * weekly_rent
        is_paused_until: nil,
        active_agreement: false,
        last_communication_date: 8.days.ago.to_date,
        last_communication_action: pre_nosp_warning_letter
      },
      {
        outcome: :send_NOSP,
        nosps_in_last_year: 0,
        nosp_expiry_date: 1.month.ago.to_date,
        weekly_rent: 5,
        balance: 25.0, # 5 * weekly_rent
        is_paused_until: nil,
        active_agreement: false,
        last_communication_date: 7.months.ago.to_date,
        last_communication_action: 'ZR2' # Stage 02 Complete / Letter 2 Sent
      },
      {
        outcome: :send_NOSP,
        nosps_in_last_year: 0,
        nosp_expiry_date: '',
        weekly_rent: 5,
        balance: 25.0, # 5 * weekly_rent
        is_paused_until: nil,
        active_agreement: true,
        last_communication_date: 8.days.ago.to_date,
        last_communication_action: pre_nosp_warning_letter
      },
      {
        outcome: :send_NOSP,
        nosps_in_last_year: 0,
        nosp_expiry_date: '',
        weekly_rent: 5,
        balance: 25.0, # 5 * weekly_rent
        is_paused_until: nil,
        active_agreement: false,
        last_communication_date: 8.days.ago.to_date,
        last_communication_action: pre_nosp_warning_letter
      }
    ]

    condition_matrix.each do |options|
      message = options.each_with_object([]) do |(k, v), m|
        next m if k == :outcome
        m << "'#{k}' is '#{v}'"
        m
      end.join(', ')

      context "when #{message}" do
        let(:nosps_in_last_year) { options[:nosps_in_last_year] }
        let(:last_communication_date) { options[:last_communication_date] }
        let(:weekly_rent) { options[:weekly_rent] }
        let(:balance) { options[:balance] }
        let(:is_paused_until) { options[:is_paused_until] }
        let(:active_agreement) { options[:active_agreement] }
        let(:last_communication_action) { options[:last_communication_action] }
        let(:nosp_expiry_date) { options[:nosp_expiry_date] }

        it "returns `#{options[:outcome]}`" do
          expect(subject).to eq(options[:outcome])
        end
      end
    end
  end

  context 'when testing `apply_for_court_date`' do
    court_warning_letter_code = 'IC4'.freeze
    condition_matrix = [
      {
        outcome: :no_action,
        nosps_in_last_year: 1,
        nosp_served_date: 26.days.ago.to_date,
        weekly_rent: 5,
        balance: 25.0, # 5 * weekly_rent
        is_paused_until: nil,
        active_agreement: false,
        last_communication_action: court_warning_letter_code,
        courtdate: '',
        last_communication_date: 1.day.ago.to_date
      },
      {
        outcome: :no_action,
        nosps_in_last_year: 1,
        nosp_served_date: 26.days.ago.to_date,
        weekly_rent: 5,
        balance: 25.0, # 5 * weekly_rent
        is_paused_until: nil,
        active_agreement: false,
        last_communication_action: court_warning_letter_code,
        courtdate: '',
        last_communication_date: 3.weeks.ago.to_date
      },
      {
        outcome: :no_action,
        nosps_in_last_year: 0,
        nosp_served_date: '',
        weekly_rent: 5,
        balance: 25.0, # 5 * weekly_rent
        is_paused_until: nil,
        active_agreement: true,
        last_communication_action: court_warning_letter_code,
        courtdate: '',
        last_communication_date: 3.weeks.ago.to_date
      },
      {
        outcome: :no_action,
        nosps_in_last_year: 1,
        nosp_served_date: 29.days.ago.to_date,
        weekly_rent: 5,
        balance: 10.0, # 2 * weekly_rent
        is_paused_until: nil,
        active_agreement: true,
        last_communication_action: court_warning_letter_code,
        courtdate: '',
        last_communication_date: 3.weeks.ago.to_date
      },
      {
        outcome: :no_action,
        nosps_in_last_year: 1,
        nosp_served_date: 29.days.ago.to_date,
        weekly_rent: 5,
        balance: 25.0, # 5 * weekly_rent
        is_paused_until: 1.day.from_now.to_date,
        active_agreement: true,
        last_communication_action: court_warning_letter_code,
        courtdate: '',
        last_communication_date: 3.weeks.ago.to_date
      },
      {
        outcome: :no_action,
        nosps_in_last_year: 1,
        nosp_served_date: 29.days.ago.to_date,
        weekly_rent: 5,
        balance: 25.0, # 5 * weekly_rent
        is_paused_until: nil,
        active_agreement: true,
        last_communication_action: 'ZR3', # ZR3 is NOSP is served over 28 days ago.
        courtdate: '',
        last_communication_date: 3.weeks.ago.to_date
      },
      {
        outcome: :apply_for_court_date,
        nosps_in_last_year: 1,
        nosp_served_date: 29.days.ago.to_date,
        weekly_rent: 5,
        balance: 25.0, # 5 * weekly_rent
        is_paused_until: nil,
        active_agreement: true,
        last_communication_action: court_warning_letter_code,
        courtdate: '',
        last_communication_date: 3.weeks.ago.to_date
      },
      {
        outcome: :apply_for_court_date,
        nosps_in_last_year: 1,
        nosp_served_date: 29.days.ago.to_date,
        weekly_rent: 5,
        balance: 25.0, # 5 * weekly_rent
        is_paused_until: nil,
        active_agreement: false,
        last_communication_action: court_warning_letter_code,
        courtdate: '',
        last_communication_date: 3.weeks.ago.to_date
      },
      {
        outcome: :apply_for_court_date,
        nosps_in_last_year: 1,
        nosp_served_date: 29.days.ago.to_date,
        weekly_rent: 5,
        balance: 25.0, # 5 * weekly_rent
        is_paused_until: nil,
        active_agreement: false,
        last_communication_action: court_warning_letter_code,
        courtdate: 5.days.ago.to_date,
        last_communication_date: 3.weeks.ago.to_date
      },
      {
        outcome: :no_action,
        nosps_in_last_year: 1,
        nosp_served_date: 29.days.ago.to_date,
        weekly_rent: 5,
        balance: 25.0, # 5 * weekly_rent
        is_paused_until: nil,
        active_agreement: false,
        last_communication_action: court_warning_letter_code,
        courtdate: 5.days.ago.to_date,
        last_communication_date: 1.week.ago.to_date
      },
      {
        outcome: :no_action,
        nosps_in_last_year: 1,
        nosp_served_date: 29.days.ago.to_date,
        weekly_rent: 5,
        balance: 25.0, # 5 * weekly_rent
        is_paused_until: nil,
        active_agreement: false,
        last_communication_action: court_warning_letter_code,
        courtdate: 2.weeks.from_now.to_date,
        last_communication_date: 3.weeks.ago.to_date
      }
    ]

    condition_matrix.each do |options|
      message = options.each_with_object([]) do |(k, v), m|
        next m if k == :outcome
        m << "'#{k}' is '#{v}'"
        m
      end.join(', ')

      context "when #{message}" do
        let(:nosps_in_last_year) { options[:nosps_in_last_year] }
        let(:nosp_served_date) { options[:nosp_served_date] }
        let(:last_communication_date) { options[:last_communication_date] }
        let(:weekly_rent) { options[:weekly_rent] }
        let(:balance) { options[:balance] }
        let(:is_paused_until) { options[:is_paused_until] }
        let(:active_agreement) { options[:active_agreement] }
        let(:last_communication_action) { options[:last_communication_action] }
        let(:courtdate) { options[:courtdate] }

        it "returns `#{options[:outcome]}`" do
          expect(subject).to eq(options[:outcome])
        end
      end
    end
  end

  context 'when testing `send_court_warning_letter`' do
    condition_matrix = [
      {
        outcome: :no_action,
        nosps_in_last_year: 0,
        nosp_served_date: 60.weeks.ago.to_date,
        weekly_rent: 5,
        balance: 15.0, # 3 * weekly_rent
        is_paused_until: nil,
        active_agreement: false,
        last_communication_action: nil
      },
      {
        outcome: :no_action,
        nosps_in_last_year: 0,
        nosp_served_date: 60.weeks.ago.to_date,
        weekly_rent: 5,
        balance: 50.0, # 10 * 5 weekly_rent
        is_paused_until: nil,
        active_agreement: false,
        last_communication_action: nil
      },
      {
        outcome: :no_action,
        nosps_in_last_year: 1,
        nosp_served_date: 1.day.ago.to_date,
        weekly_rent: 5,
        balance: 15.0, # 3 * weekly_rent
        is_paused_until: nil,
        active_agreement: false,
        last_communication_action: nil
      },
      {
        outcome: :no_action,
        nosps_in_last_year: 1,
        nosp_served_date: 1.day.ago.to_date,
        weekly_rent: 5,
        balance: 50.0, # 10 * weekly_rent
        is_paused_until: nil,
        active_agreement: false,
        last_communication_action: nil
      },
      {
        outcome: :no_action,
        nosps_in_last_year: 1,
        nosp_served_date: 29.days.ago.to_date,
        weekly_rent: 5,
        balance: 15.0, # 3 * weekly_rent
        is_paused_until: nil,
        active_agreement: false,
        last_communication_action: nil
      },
      {
        outcome: :no_action,
        nosps_in_last_year: 1,
        nosp_served_date: 29.days.ago.to_date,
        weekly_rent: 5,
        balance: 25.0, # 5 * weekly_rent
        is_paused_until: 1.month.from_now.to_date,
        active_agreement: false,
        last_communication_action: nil
      },
      {
        outcome: :no_action,
        nosps_in_last_year: 1,
        nosp_served_date: 29.days.ago.to_date,
        weekly_rent: 5,
        balance: 25.0, # 5 * weekly_rent
        is_paused_until: nil,
        active_agreement: true,
        last_communication_action: nil
      },
      {
        outcome: :apply_for_court_date,
        nosps_in_last_year: 1,
        nosp_served_date: 29.days.ago.to_date,
        weekly_rent: 5,
        balance: 25.0, # 5 * weekly_rent
        is_paused_until: nil,
        active_agreement: false,
        last_communication_action: 'IC4'
      },
      {
        outcome: :send_court_warning_letter,
        nosps_in_last_year: 1,
        nosp_served_date: 29.days.ago.to_date,
        weekly_rent: 5,
        balance: 25.0, # 5 * weekly_rent
        is_paused_until: nil,
        active_agreement: false,
        last_communication_action: nil
      }
    ]

    condition_matrix.each do |options|
      message = options.each_with_object([]) do |(k, v), m|
        next m if k == :outcome
        m << "'#{k}' is '#{v}'"
        m
      end.join(', ')

      context "when #{message}" do
        let(:nosps_in_last_year) { options[:nosps_in_last_year] }
        let(:nosp_served_date) { options[:nosp_served_date] }
        let(:last_communication_date) { options[:last_communication_date] }
        let(:weekly_rent) { options[:weekly_rent] }
        let(:balance) { options[:balance] }
        let(:is_paused_until) { options[:is_paused_until] }
        let(:active_agreement) { options[:active_agreement] }
        let(:last_communication_action) { options[:last_communication_action] }

        it "returns `#{options[:outcome]}`" do
          expect(subject).to eq(options[:outcome])
        end
      end
    end
  end
end
