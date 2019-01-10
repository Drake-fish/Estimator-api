Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :projects do
    resources :estimates
  end
  get '/calculate/:id', action: :calculate_estimate, controller: 'projects'
  get '/calculate/:id/weighted', action: :calculate_weighted, controller: 'projects'
  get '/calculate/all/:id', action: :average_all_estimates, controller: 'projects'
  get '/calculate/all/weighted/:id', action: :average_all_weighted_estimates, controller: 'projects' 
end
