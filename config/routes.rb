Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  # Root path showing the form and (after submission) results
  post "/", to: "pages#home"
  
  # Analysis routes
  get ':game_slug', to: 'pages#show_analysis', as: :show_analysis
  get ':game_slug/:id', to: 'pages#show_analysis', as: :show_analysis_version

  # API endpoint for JSON data
  get "steam_data/:appid", to: "steam_data#show"

  resources :games do
    member do
      get 'steam_images/analyze', to: 'steam_images#analyze'
    end
  end
end
