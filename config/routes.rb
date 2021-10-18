Rails.application.routes.draw do
  devise_for :users
  
  root to: 'homes#top'
  get '/about' => 'homes#about'
  resources :users, only: [:index, :show, :edit, :create, :update, :destroy]
  resources :posts, only: [:new, :index, :show, :edit, :create, :update, :destroy]
  resources :post_comments, only: [:create, :destroy]
  resources :favorites, only: [:create, :destroy]

end
