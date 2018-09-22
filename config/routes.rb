Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :agencies, only: %i[index show]
  resources :calendar_dates, only: %i[index show]
  resources :calendars, only: %i[index show]
  resources :fair_attributes, only: %i[index show]
  resources :fair_rules, only: %i[index show]
  resources :feed_infos, only: %i[index show]
  resources :frequencies, only: %i[index show]
  resources :routes, only: %i[index show]
  resources :shapes, only: %i[index show]
  resources :stops, only: %i[index show]
  resources :transfers, only: %i[index show]
  resources :trips, only: %i[index show]
end
