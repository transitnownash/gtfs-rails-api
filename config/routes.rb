Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :agencies, only: %i[index show]
  resources :calendar_dates, only: %i[index show]
  resources :calendars, only: %i[index show]
  resources :fare_attributes, only: %i[index show]
  resources :fare_rules, only: %i[index show]
  resources :feed_infos, only: %i[index show]
  resources :frequencies, only: %i[index show]

  get '/routes', to: 'routes#index', as: 'routes'
  get '/routes/:route_gid', to: 'routes#show', as: 'route'
  get '/routes/:route_gid/trips', to: 'routes#show_trips', as: 'route_trips'

  resources :shapes, only: %i[index show]
  resources :stops, only: %i[index show]
  resources :transfers, only: %i[index show]

  get '/trips', to: 'trips#index', as: 'trips'
  get '/trips/:trip_gid', to: 'trips#show', as: 'trip'
  get '/trips/:trip_gid/stop_times', to: 'trips#show_stop_times', as: 'trip_stop_times'
  get '/trips/:trip_gid/shape', to: 'trips#show_shape', as: 'trip_shape'
end
