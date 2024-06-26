# frozen_string_literal: true

Rails.application.routes.draw do
  get 'up' => 'rails/health#show', as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resource :fridge, only: [] do
        get '', to: 'fridge#list_ingredients'
        post 'add_ingredient', to: 'fridge#add_ingredient'
        patch 'update_ingredient', to: 'fridge#update_ingredient'
        delete 'remove_ingredient', to: 'fridge#remove_ingredient'
      end

      resources :ingredients, only: [] do
        get '', to: 'ingredients#list', on: :collection
        get 'search', on: :collection
      end

      resources :recipes, only: [] do
        get '', to: 'recipes#list', on: :collection
        get 'search', on: :collection
        post 'suggest', on: :collection
      end
    end
  end
end
