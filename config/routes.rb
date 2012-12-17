Speculator::Application.routes.draw do

  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  match "mkt_data"=>"home#mkt_data"
  match "update_new_low_date"=>"new_lows#update_all_date"
  match "stocks/:symbol" => "stocks#show"
  match "stock_partial" => "stocks#show_partial"
  match "fix_stock_units/:symbol" => "stocks#fix_units"
  match "update_stock/:symbol" => "stocks#update_data"
  match "recalc_stock/:symbol" => "stocks#recalc_data"
  match "new_lows/:date" => "new_lows#index"
  match "tasks" => "tasks#index"
  match "scrape_new_lows" => "tasks#stock_scrape"
  match "test_task" => "tasks#test_task"
  resources :new_lows
  resources :opinions

  resources :stocks do
    resources :notes
    resources :links
  end


  authenticated :user do
    root :to => 'home#index'
  end
  root :to => "home#index"
  devise_for :users
  resources :users, :only => [:show, :index]
end
