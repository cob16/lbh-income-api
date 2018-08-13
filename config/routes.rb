Rails.application.routes.draw do
  get '/api/v1/my-cases', to: 'my_cases#index'
end
