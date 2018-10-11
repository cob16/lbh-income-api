Rails.application.routes.draw do
  get '/api/v1/my-cases', to: 'my_cases#index'
  get '/api/v1/sync-cases', to: 'my_cases#sync'
  post '/api/v1/users/find-or-create', to: 'users#create'
  patch '/api/v1/tenancies/set-pause-status', to: 'tenancies#update'
end
