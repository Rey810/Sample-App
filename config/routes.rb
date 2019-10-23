Rails.application.routes.draw do
  #by using get we arrange for the route to respond to a GET request
  get 'static_pages/home'

  get 'static_pages/help'

  get 'static_pages/about'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'application#hello'
end
