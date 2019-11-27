shared_examples 'TenancyClassification' do |condition_matrix|
  subject { assign_classification.execute }

  let(:assign_classification) { Hackney::Income::TenancyPrioritiser::TenancyClassification.new(case_priority, criteria) }
  let(:criteria) { Stubs::StubCriteria.new(attributes) }
  let(:case_priority) { build(:case_priority, is_paused_until: is_paused_until) }

  let(:is_paused_until) { nil }
  let(:attributes) do
    {
      balance: balance,
      weekly_rent: weekly_rent,
      last_communication_date: last_communication_date,
      last_communication_action: last_communication_action,
      active_agreement: active_agreement,
      nosps_in_last_year: nosps_in_last_year,
      nosp_served_date: nosp_served_date,
      nosp_expiry_date: nosp_expiry_date,
      courtdate: courtdate,
      eviction_date: eviction_date
    }
  end

  let(:balance) { 5.00 }
  let(:weekly_rent) { 5.0 }
  let(:last_communication_date) { '' }
  let(:last_communication_action) { nil }
  let(:active_agreement) { nil }
  let(:nosps_in_last_year) { nil }
  let(:nosp_served_date) { '' }
  let(:nosp_expiry_date) { '' }
  let(:courtdate) { '' }
  let(:eviction_date) { '' }

  condition_matrix.each do |options|
    message = options.each_with_object([]) do |(k, v), m|
      next m if k == :outcome
      m << "'#{k}' is '#{v}'"
      m
    end.join(', ')

    context "when #{message}" do
      let(:is_paused_until) { options[:is_paused_until] }

      let(:balance) { options[:balance] }
      let(:weekly_rent) { options[:weekly_rent] }
      let(:last_communication_date) { options[:last_communication_date] }
      let(:last_communication_action) { options[:last_communication_action] }
      let(:active_agreement) { options[:active_agreement] }
      let(:nosps_in_last_year) { options[:nosps_in_last_year] }
      let(:nosp_served_date) { options[:nosp_served_date] }
      let(:nosp_expiry_date) { options[:nosp_expiry_date] }
      let(:courtdate) { options[:courtdate] }
      let(:eviction_date) { options[:eviction_date] || '' }

      it "returns `#{options[:outcome]}`" do
        expect(subject).to eq(options[:outcome])
      end
    end
  end
end
