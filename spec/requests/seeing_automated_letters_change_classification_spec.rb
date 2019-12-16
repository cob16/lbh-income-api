describe 'seeing automated letters change classification' do
  it 'works' do
    # set up a case that needs a letter one sent
    # write_uh_entries(classification: 'send_letter_one')

    # expect(response.body[:case][:classification]).to eq('send_letter_one')
    let(:automate_sending_letters) { UseCases::AutomateSendingLetters.new }

    let(:attributes) {
      {
        nosps_in_last_year: 0,
        nosp_expiry_date: '',
        weekly_rent: 5,
        balance: 6.0,
        is_paused_until: '',
        active_agreement: false,
        last_communication_date: 2.weeks.ago.to_date,
        last_communication_action: '',
        eviction_date: '',
        courtdate: ''
      }
    }

    let(:criteria) { Stubs::StubCriteria.new(attributes) }

    let(:case_priority) {
      build(:case_priority,
            tenancy_ref: tenancy_ref,
            classification: :send_letter_one,
            patch_code: Faker::Number.number(4))
    }

    post "cases/#{id}"

    # run automation
    # ???

    # look at the case and check it's got the right data
    get "cases/#{id}"

    expect(response.body[:case][:classification]).to eq('no_action')
  end
end

