# frozen_string_literal: true

module Api
  module V1
    class FridgeController < ApplicationController
      def add_ingredient
        ingredient_id = add_ingredient_params[:id]
        ingredient = Ingredient.find(ingredient_id)
        FridgeIngredient.create(fridge:, ingredient:)
      end

      def update_ingredient; end

      def remove_ingredient; end

      private

      def fridge
        Fridge.first || Fridge.create
      end

      def add_ingredient_params
        params.require(:ingredient).permit(:id)
      end
    end
  end
end
