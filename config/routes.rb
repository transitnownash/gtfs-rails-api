# frozen_string_literal: true

Rails.application.routes.draw do
  root 'default#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get '/agencies', to: 'agencies#index', as: 'agencies'
  get '/agencies/:agency_gid', to: 'agencies#show', as: 'agency'

  get '/calendar_dates', to: 'calendar_dates#index', as: 'calendar_dates'
  get '/calendar_dates/:service_gid', to: 'calendar_dates#show', as: 'calendar_date'

  get '/calendars', to: 'calendars#index', as: 'calendars'
  get '/calendars/:service_gid', to: 'calendars#show', as: 'calendar'
  get '/calendars/:service_gid/trips', to: 'calendars#show_trips', as: 'calendar_trips'
  get '/calendars/:service_gid/calendar_dates', to: 'calendars#show_calendar_dates', as: 'calendar_calendar_dates'

  resources :fare_attributes, only: %i[index show]
  resources :fare_rules, only: %i[index show]
  resources :feed_infos, only: %i[index show]
  resources :frequencies, only: %i[index show]

  get '/routes', to: 'routes#index', as: 'routes'
  get '/routes/:route_gid', to: 'routes#show', as: 'route'
  get '/routes/:route_gid/trips', to: 'routes#show_trips', as: 'route_trips'
  get '/routes/:route_gid/shapes', to: 'routes#show_shapes', as: 'route_shapes'
  get '/routes/:route_gid/stops', to: 'routes#show_stops', as: 'route_stops'

  get '/shapes', to: 'shapes#index', as: 'shapes'
  get '/shapes/:shape_gid', to: 'shapes#show', as: 'shape'

  latitude_regex = /(\+|-)?(?:90(?:(?:\.0{1,6})?)|(?:[0-9]|[1-8][0-9])(?:(?:\.[0-9]{1,6})?))/
  longitude_regex = /(\+|-)?(?:180(?:(?:\.0{1,6})?)|(?:[0-9]|[1-9][0-9]|1[0-7][0-9])(?:(?:\.[0-9]{1,6})?))/

  get '/stops', to: 'stops#index', as: 'stops'
  get '/stops/near/:latitude,:longitude(/:radius)', to: 'stops#nearby',
                                                    as: 'stops_nearby',
                                                    constraints: {
                                                      latitude: latitude_regex,
                                                      longitude: longitude_regex
                                                    }
  get '/stops/:stop_gid', to: 'stops#show', as: 'stop'
  get '/stops/:stop_gid/stop_times', to: 'stops#show_stop_times', as: 'stop_stop_times'
  get '/stops/:stop_gid/trips', to: 'stops#show_trips', as: 'stop_trips'
  get '/stops/:stop_gid/routes', to: 'stops#show_routes', as: 'stop_routes'

  resources :stop_times, only: %i[index]
  resources :transfers, only: %i[index show]

  get '/trips', to: 'trips#index', as: 'trips'
  get '/trips/:trip_gid', to: 'trips#show', as: 'trip'
  get '/trips/:trip_gid/stop_times', to: 'trips#show_stop_times', as: 'trip_stop_times'
  get '/trips/:trip_gid/shape', to: 'trips#show_shape', as: 'trip_shape'
  get '/trips/:trip_gid/block', to: 'trips#show_block', as: 'trip_block'

  get '/realtime/alerts', to: 'realtime#alerts', as: 'realtime_alerts'
  get '/realtime/vehicle_positions', to: 'realtime#vehicle_positions', as: 'realtime_vehicle_positions'
  get '/realtime/trip_updates', to: 'realtime#trip_updates', as: 'realtime_trip_updates'
end
