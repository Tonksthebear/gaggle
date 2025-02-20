Gaggle::Engine.routes.draw do
  root to: "overviews#show"

  resources :channels do
    resources :messages, only: [ :create ], module: :channels
    resources :gooses, only: [ :index, :create, :destroy ]
  end

  resources :messages, only: [ :destroy ]

  resources :gooses do
    scope module: :gooses do
      resources :sessions, only: [ :index, :create, :destroy ]
    end
  end

  resources :sessions, only: [ :show, :update, :destroy ]
end
