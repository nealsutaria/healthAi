Rails.application.routes.draw do
  # Devise routes for users, including Google OmniAuth callbacks
  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks'
  }

  # Resourceful routes for health records
  resources :records do
    post :doctor_suggestion, on: :member
  end

  # Health check endpoint
  get "up" => "rails/health#show", as: :rails_health_check

  # Route for the main chat page
  get 'chat', to: 'chat#index', as: :chat

  # Route for handling sending messages to the AI bot
  post 'chat/send_message', to: 'chat#send_message', as: :send_chat_message
  post "chat/clear", to: "chat#clear", as: :clear_chat

  # Root page
  root "records#index"
end

