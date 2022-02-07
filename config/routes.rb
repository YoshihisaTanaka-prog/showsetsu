Rails.application.routes.draw do
  resources :characters
  resources :synopses
  resources :stories
  resources :chapters
  resources :titles
  resources :steps
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  post 'sort-step/:iid/:jid', to: 'steps#sort', as: 'sort_step'

  root 'tops#index'
end
