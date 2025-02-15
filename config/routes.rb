Gaggle::Engine.routes.draw do
  root to: "threads#index"

  resources :threads do
    resources :messages, only: [ :new, :create ], module: :threads
  end

  resources :messages, except: [ :new, :create ]
  resources :goose
end
