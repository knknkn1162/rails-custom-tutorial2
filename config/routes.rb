Rails.application.routes.draw do
  get '/help', to: 'static_pages#help'
  get '/about', to: 'static_pages#about'
  get '/contact', to: 'static_pages#contact'
  root 'static_pages#home'

  resources :users
  # we use 'signup_path' instead of default path '/users'
  get '/signup', to: 'users#new'
  # strictly, this setting may be redundant.
  post '/signup', to: 'users#create'
end
