Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :agencies, only: %i[index show]
  resources :calendar_dates, only: %i[index show]
  resources :calendars, only: %i[index show]
  resources :fare_attributes, only: %i[index show]
  resources :fare_rules, only: %i[index show]
  resources :feed_infos, only: %i[index show]
  resources :frequencies, only: %i[index show]
  resources :routes, only: %i[index show]
  resources :shapes, only: %i[index show]
  resources :stops, only: %i[index show]
  resources :transfers, only: %i[index show]
  resources :trips, only: %i[index show]

  get '/trips/:id/stop_times', to: 'trips#show_stop_times', as: 'trip_stop_times'
  get '/trips/:id/shape', to: 'trips#show_shape', as: 'trip_shape'
end
