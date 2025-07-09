Rails.application.routes.draw do
  get 'pages/home'
  # Devise routes for users, including Google OmniAuth callbacks
  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks'
  }

  # Resourceful routes for health records
  resources :records do
    post :doctor_suggestion, on: :member
    post :analyze_image, on: :member
  end

  # Health check endpoint
  get "up" => "rails/health#show", as: :rails_health_check

  # Route for the main chat page
  get 'chat', to: 'chat#index', as: :chat

  # Route for handling sending messages to the AI bot
  post 'chat/send_message', to: 'chat#send_message', as: :send_chat_message
  post "chat/clear", to: "chat#clear", as: :clear_chat

  # Root page
  #root "records#index"

  authenticated :user do
    root to: "records#index", as: :authenticated_root
  end

  unauthenticated do
    root to: "pages#home", as: :unauthenticated_root
  end

  # For the static page
  get "about", to: "pages#home"

  get "privacy", to: "pages#privacy", as: :privacy
  get "terms", to: "pages#terms", as: :terms
end

