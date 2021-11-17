Rails.application.routes.draw do
  devise_for :users

  root to: 'homes#top'
  get '/about' => 'homes#about'
  patch '/withdraw' => 'users#withdraw'
  get '/unsubscribe' => 'users#unsubscribe'
  resources :users, only: [:index, :show, :edit, :create, :update, :destroy] do
    resource :relationships, only: [:create, :destroy]
    get :follows, on: :member
    get :followers, on: :member
  end
  resources :posts, only: [:new, :create, :index, :show, :edit, :update, :destroy] do
    resource :favorites, only: [:create, :destroy]
    resources :post_comments, only: [:create, :destroy]
  end


end
