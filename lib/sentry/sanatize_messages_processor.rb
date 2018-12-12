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
