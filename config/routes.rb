Rails.application.routes.draw do
  # resources :characters
  # resources :synopses
  # resources :stories
  # resources :chapters
  # resources :titles
  # resources :steps
  devise_for :users, controllers: {
    sessions: 'users/sessions'
  }
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  ['character', 'synopsis', 'story', 'chapter', 'title', 'step'].each do |model|
    models = model.pluralize
    post models + '/index',              to: models + '#index',   as: models
    post models,                         to: models + '#create'
    post models + '/new',                to: models + '#new',     as: 'new_' + model
    post models + '/:id/edit',           to: models + '#edit',    as: 'edit_' + model
    post models + '/:id/show',                to: models + '#show',    as: model
    patch models + '/:id/update',               to: models + '#update'
    delete models + '/:id/delete',              to: models + '#destroy'
    post 'sort-' + model + '/:iid/:jid', to: models + '#sort',    as: 'sort_' + model
  end

  post 'fetch-work-session', to: 'tops#fetch_work_session'
  post 'tops', to: 'tops#index'
  post 'header', to: 'tops#header'
  root 'tops#index'

  get 'no-page', to: 'tops#nopage'
  # get '*unmatched_route', to: 'tops#unmatched'
  # post '*unmatched_route', to: 'tops#unmatched'
  # patch '*unmatched_route', to: 'tops#unmatched'
  # delete '*unmatched_route', to: 'tops#unmatched'

end
