Rails.application.routes.draw do
  get '/api/v1/my-cases', to: 'my_cases#index'
  get '/api/v1/sync-cases', to: 'my_cases#sync'
  post '/api/v1/find-or-create-user', to: 'users#create'
end
