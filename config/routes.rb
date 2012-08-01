Speculator::Application.routes.draw do

  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  match "stocks/:symbol" => "stocks#show"
  match "stock_partial" => "stocks#partial"
  match "fix_stock_units/:symbol" => "stocks#fix_units"
  match "update_stock/:symbol" => "stocks#update_data"
  match "new_lows/:date" => "new_lows#index"
  resources :new_lows
  resources :opinions
  resources :stocks

  authenticated :user do
    root :to => 'home#index'
  end
  root :to => "home#index"
  devise_for :users
  resources :users, :only => [:show, :index]
end
