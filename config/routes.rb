Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get "/", to: "welcome#index"

# I had to move this to the top of the file to get my form_for to create/edit items
# to work properly
  namespace :merchant  do
    get '/', to: 'dashboard#show'
    resources :items, only: [:index, :show, :update, :destroy, :new, :create, :edit]
    resources :orders, only: [:show, :update]
    resources :coupons, only: [:index, :show, :new, :create, :edit, :update, :destroy]
  end

  # get "/merchants", to: "merchants#index"
  # get "/merchants/new", to: "merchants#new"
  # get "/merchants/:id", to: "merchants#show"
  # post "/merchants", to: "merchants#create"
  # get "/merchants/:id/edit", to: "merchants#edit"
  # patch "/merchants/:id", to: "merchants#update"
  # delete "/merchants/:id", to: "merchants#destroy"
  # get "/merchants/:merchant_id/items", to: "items#index"
  post "/merchants/:merchant_id/items", to: "items#create"
  resources :merchants do
    # get "/merchants/:merchant_id/items/new", to: "items#new"
    resources :items, only: [:new, :index]
  end

  # get "/items", to: "items#index"
  # get "/items/:id", to: "items#show"
  # get "/items/:id/edit", to: "items#edit"
  # patch "/items/:id", to: "items#update"
  # delete "/items/:id", to: "items#destroy"
  resources :items, only: [:index, :show, :edit, :update, :destroy] do
      resources :reviews, only: [:new, :create]
  # get "/items/:item_id/reviews/new", to: "reviews#new"
  # post "/items/:item_id/reviews", to: "reviews#create"
  end


  # get "/reviews/:id/edit", to: "reviews#edit"
  # patch "/reviews/:id", to: "reviews#update"
  # delete "/reviews/:id", to: "reviews#destroy"
  resources :reviews, only: [:edit, :update, :destroy]

# Cart is not a resource, it's a session so no resources
  get "/cart", to: "cart#show"
  post "/cart/:item_id", to: "cart#add_item"
  patch "/cart/:item_id", to: "cart#update"
  delete "/cart", to: "cart#empty"
  delete "/cart/:item_id", to: "cart#remove_item"


  # get "/orders/new", to: "orders#new"
  # get "/orders/:id", to: "orders#show"
  # patch '/orders/update/:id', to: 'orders#update'
  resources :orders, only: [:new, :show, :update]

# I believe this all stay hand-rolled since the profile id is never exposed in a route
# and creating a resource for profile, even if all verbs are 'excepted' creates
# routes like '/profile/:profile_id/orders'
  get '/profile/orders', to: 'orders#index'
  post "/profile/orders", to: "orders#create"
  get "/profile/orders/:order_id", to: "orders#show"
  delete "/profile/orders/:order_id", to: "orders#destroy"

  get "/users/register", to: "users#new"
  post "/users", to: "users#create"
  get "/profile", to: "users#show"
  get "/profile/edit", to: "users#edit"
  patch "/profile", to: "users#update"

# Sessions, so no resources
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  post '/coupon', to: 'coupon_sessions#create'

#the resources below were all added after the group project as part of the solo project.


  namespace :admin do
    get '/', to: 'dashboard#index'
    resources :users, only: [:index, :show] do
      resources :orders, only: [:show, :destroy]
    end
    resources :merchants, only: [:index, :show, :update] do
      resources :items, only: [:index, :new, :create, :edit, :update, :destroy]
    end
  end
end
