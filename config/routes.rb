Gaggle::Engine.routes.draw do
  root to: "threads#index"

  resources :threads do
    resources :messages, only: [ :new, :create ], module: :threads
  end

  resources :messages, except: [ :new, :create ]

  resources :gooses do
    scope module: :gooses do
      resources :sessions, only: [ :index, :create ]
    end
  end

  resources :sessions, only: [ :show, :update, :destroy ]
end
