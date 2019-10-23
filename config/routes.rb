Rails.application.routes.draw do
  #by using get we arrange for the route to respond to a GET request
  get 'static_pages/home'
  get 'static_pages/help'
  get 'static_pages/about'
  get 'static_pages/contact'
  root 'application#hello'
end
