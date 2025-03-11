Gaggle::Engine.routes.draw do
  root to: "overviews#show"

  resources :channels, mcp: true do
    scope module: :channels do
      resources :messages, only: [ :create ], mcp: true
    end
  end

  resources :messages, only: [ :destroy ], mcp: true

  resources :gooses, mcp: [ :index ] do
    scope module: :gooses do
      resources :sessions, only: [ :index, :create, :destroy ]
    end
  end

  resources :sessions, only: [ :show, :update, :destroy ]
end
