class SanatizeMessagesProcessor < Raven::Processor
  def process(data)
    params = data.dig(:extra, :params)
    return data unless params && params[:controller] == 'messages'

    params[:message]   = { sanatized: true }
    params[:variables] = { sanatized: true }
    params[:phone_number] = STRING_MASK
    params[:tenancy_ref] = STRING_MASK
    params[:phone_number] = STRING_MASK

    data
  end
end

__END__
{
action: send_email,
controller: messages,
email_address: soraya.clarke@hackney.gov.uk,
message: {
  email_address: soraya.clarke@hackney.gov.uk,
  reference: manual_053235/01,
  template_id: da658c4f-daa6-4691-8ec0-035837089fb5,
  tenancy_ref: 053235/01,
  variables: {
    balance: 501.89,
    first name: Luz,
    formal name: Miss Littel,
    full name: Miss Luz Littel,
    last name: Littel,
    title: Miss
  }
  },
  reference: manual_053235/01,
  template_id: da658c4f-daa6-4691-8ec0-035837089fb5,
  tenancy_ref: 053235/01,
  variables: {
  balance: 501.89,
  first name: Luz,
  formal name: Miss Littel,
  full name: Miss Luz Littel,
  last name: Littel,
  title: Miss
  }
}
