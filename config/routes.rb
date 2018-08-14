Rails.application.routes.draw do
  get '/api/v1/my-cases', to: 'my_cases#index'
  get '/api/v1/sync-cases', to: 'my_cases#sync'
end
