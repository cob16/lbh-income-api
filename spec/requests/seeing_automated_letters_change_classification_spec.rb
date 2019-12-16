describe 'seeing automated letters change classification' do
  it 'works' do
    # set up a case that needs a letter one sent
    write_uh_entries(classification: 'send_letter_one')

    expect(response.body[:case][:classification]).to eq('send_letter_one')
    # run automation
    # ???

    # look at the case and check it's got the right data
    get "cases/#{id}"

    expect(response.body[:case][:classification]).to eq('no_action')
  end
end
