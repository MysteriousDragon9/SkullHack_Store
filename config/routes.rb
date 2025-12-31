Rails.application.routes.draw do
  devise_for :users

  # Root
  root "products#index"

  # Catalog
  resources :categories, only: [ :index, :show ]
  resources :products, only: [ :index, :show ] do
    resources :reviews, only: [ :create, :destroy ]
  end

  # Cart with explicit item routes (matches CartsController methods)
  resource :cart, only: [ :show ] do
    member do
      post   :add_item
      patch  :update_item
      delete :remove_item
      post   :checkout
    end
  end   # <-- this was missing

  # Orders
  resources :orders, only: [ :index, :new, :create, :show ] do
    member do
      get :pay
      post :capture
    end
  end

  # Static pages
  get "/about",   to: "pages#show", defaults: { slug: "about" }
  get "/contact", to: "pages#show", defaults: { slug: "contact" }

  # Health/PWA
  get "up"             => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest"       => "rails/pwa#manifest", as: :pwa_manifest

  # Errors
  get "/404", to: "errors#not_found"
  get "/500", to: "errors#internal_error"

  # Admin namespace
  namespace :admin do
    root to: "dashboard#index"
    resources :products do
      member do
        delete :purge_image
        delete "purge_gallery_image/:image_id", action: :purge_gallery_image, as: :purge_gallery_image
      end
    end
    resources :categories
    resources :orders, only: [ :index, :show, :update ]
    resources :pages
    resources :provinces
  end
  post "/stripe/webhook", to: "stripe_webhooks#create"
end
