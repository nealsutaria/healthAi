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

  get "copilot", to: "copilot#index"

  resources :appointment_briefs, only: [:index, :show, :create, :destroy] do
    post :regenerate, on: :member
  end

  namespace :clinic do
    resources :organizations, only: [:index, :new, :create, :show] do
      resources :memberships, only: [:index, :destroy]
      resources :clinic_invitations, only: [:new, :create, :destroy]
      resources :prior_auth_drafts, only: [:index, :new, :create, :show, :edit, :update, :destroy]
    end
    get "invitations/:token", to: "invitation_acceptances#show", as: :invitation_acceptance
    post "invitations/:token/accept", to: "invitation_acceptances#create", as: :accept_invitation
  end

  # For the static page
  get "about", to: "pages#home"

  get "privacy", to: "pages#privacy", as: :privacy
  get "terms", to: "pages#terms", as: :terms

  namespace :api do
    namespace :v1 do
      post "login", to: "sessions#create"
      delete "logout", to: "sessions#destroy"
      resources :records, only: [:index, :show, :create, :update, :destroy] do
        member do
          post :analyze_image
        end
      end
      get "/chat/messages", to: "chat_messages#index"
      post "/chat/messages", to: "chat_messages#create"
      delete "/chat/messages", to: "chat_messages#destroy_all"
      resources :appointment_briefs, only: [:index, :show, :create, :destroy] do
        member do
          post :regenerate
        end
      end
    end
  end
end

