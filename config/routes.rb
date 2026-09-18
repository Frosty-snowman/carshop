Rails.application.routes.draw do
  devise_for :users

  root "home#index"

  resources :products, only: %i[index show]
  resources :cart_items, only: %i[index create update destroy]
  resource :checkout, only: %i[new create]
  resources :feature_requests, only: %i[new create]
  resources :orders, only: %i[index show]
  resources :orders, only: [] do
    resource :payment, only: %i[update]
  end

  namespace :admin do
    root "dashboard#show"
    resource :shop_setting, only: %i[edit update]
    resources :categories, except: %i[show]
    get "stock", to: "stock#index", as: :stock
    patch "stock", to: "stock#update"
    resources :products do
      resources :product_variants, except: %i[index show] do
        member do
          post :replenish
        end
      end
    end
    resources :orders, only: %i[index show update]
    resources :feature_requests, only: %i[index update]
    resources :payments, only: [] do
      member do
        post :approve
        post :reject
      end
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
