Gaggle::Engine.routes.draw do
  root to: "threads#index"

  resources :threads do
    resources :messages, only: [ :create ], module: :threads
  end

  resources :messages, only: [ :destroy ]

  resources :gooses do
    scope module: :gooses do
      resources :sessions, only: [ :index, :create ]
    end
  end

  resources :sessions, only: [ :show, :update, :destroy ]
end
