# frozen_string_literal: true

module Api
  module V1
    class FridgeController < ApplicationController
      def list_ingredients
        render json: { ingredients: fridge.fridge_ingredients.to_json_list }
      end
      
      def add_ingredient
        ingredient = Ingredient.find(add_ingredient_params[:id])
        quantity = add_ingredient_params[:quantity]
        unit = Unit.find(add_ingredient_params[:unit_id])

        fridge_ingredient = FridgeIngredient.create(fridge:, ingredient:, quantity:, unit:)

        if fridge_ingredient.invalid? || fridge_ingredient.errors.any?
          render json: { errors: fridge_ingredient.errors }, status: :unprocessable_entity
        else
          render json: { fridge_ingredient: }, status: :created
        end
      end

      def update_ingredient
        fridge_ingredient = FridgeIngredient.find_by(ingredient_id: add_ingredient_params[:id])

        render json: { error: 'Ingredient not found in the fridge' }, status: :not_found unless fridge_ingredient

        quantity = add_ingredient_params[:quantity]
        unit = Unit.find(add_ingredient_params[:unit_id])

        fridge_ingredient.update(quantity:, unit:)

        if fridge_ingredient.invalid? || fridge_ingredient.errors.any?
          render json: { errors: fridge_ingredient.errors }, status: :unprocessable_entity
        else
          render json: { fridge_ingredient: }, status: :ok
        end
      end

      def remove_ingredient
        fridge_ingredient = FridgeIngredient.find_by(ingredient_id: remove_ingredient_params[:id])

        fridge_ingredient&.destroy

        render status: :no_content
      end

      private

      def fridge
        Fridge.first_or_create
      end

      def add_ingredient_params
        params.require(:ingredient).permit(:id, :quantity, :unit_id)
      end

      def update_ingredient_params
        params.require(:ingredient).permit(:id, :quantity, :unit_id)
      end

      def remove_ingredient_params
        params.require(:ingredient).permit(:id)
      end
    end
  end
end
