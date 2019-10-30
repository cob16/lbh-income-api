require 'rails_helper'

xdescribe 'downloading a letter PDF' do
  let(:real_template_id) { 'letter_before_action' }
  let(:payment_ref) { Faker::Number.number(6) }
  let(:house_ref) { Faker::Number.number(6) }
  let(:prop_ref) { Faker::Number.number(6) }
  let(:postcode) { Faker::Number.number(6) }

  it 'responds with a PDF when I call preview then documents' do
    create_uh_tenancy_agreement(prop_ref: prop_ref, tenancy_ref: Faker::Number.number(6), u_saff_rentacc: payment_ref, house_ref: house_ref)
    create_uh_househ(house_ref: house_ref, corr_preamble: 'address1', corr_desig: 'address2', corr_postcode: postcode)
    create_uh_rent(prop_ref: prop_ref, sc_leasedate: '')
    create_uh_postcode(post_code: postcode, aline1: '')

    post messages_letters_path, params: { payment_ref: payment_ref, template_id: real_template_id }

    get documents_path(response.body['document_id'])

    expect(response.headers['Content-Type']).to eq('application/pdf')
  end
end
