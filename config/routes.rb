Rails.application.routes.draw do
  get '/signup', to: 'users#new'

  root 'static_pages#home'
  #by using get we arrange for the route to respond to a GET request
  get '/help', to: 'static_pages#help'
  get '/about', to: 'static_pages#about'
  get '/contact', to: 'static_pages#contact'
  get '/signup', to: 'users#new'
  post '/signup', to: 'users#create'

  resources :users

end
