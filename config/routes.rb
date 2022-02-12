Rails.application.routes.draw do
  resources :characters
  resources :synopses
  resources :stories
  resources :chapters
  resources :titles
  resources :steps
  devise_for :users, controllers: {
    sessions: 'users/sessions'
  }
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  post 'sort-step/:iid/:jid', to: 'steps#sort', as: 'sort_step'

  post 'fetch-work-session', to: 'tops#fetch_work_session'
  root 'tops#index'

  get 'no-page', to: 'tops#nopage'
  # get '*unmatched_route', to: 'tops#unmatched'
  # post '*unmatched_route', to: 'tops#unmatched'
  # patch '*unmatched_route', to: 'tops#unmatched'
  # delete '*unmatched_route', to: 'tops#unmatched'

end
