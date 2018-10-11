Rails.application.routes.draw do
  scope '/api/v1' do
    get '/my-cases', to: 'my_cases#index'
    get '/sync-cases', to: 'my_cases#sync'
    post '/users/find-or-create', to: 'users#create'
    patch '/tenancies/:tenancy_ref', to: 'tenancies#update'
  end
end
