# frozen_string_literal: true

module Api
  module V1
    class RecipesController < ApplicationController
      include Pagy::Backend

      rescue_from Pagy::OverflowError, with: :not_found

      SORT_KEYS = %w[name].freeze
      SORT_DIRECTIONS = %w[asc desc].freeze

      DEFAULT_SORT_KEY = 'name'
      DEFAULT_SORT_DIRECTION = 'asc'

      def list
        @pagy, @records = pagy(recipes)

        pagination = {
          count: @pagy.items,
          total_count: @pagy.count,
          page: @pagy.page,
          prev_page: @pagy.prev,
          next_page: @pagy.next
        }

        render json: { recipes: @records.to_json_list, pagination: }
      end

      def search # rubocop:disable Metrics/MethodLength
        params[:search] || ''

        @records = recipes.search(params[:search])

        @pagy, @records = pagy(@records)

        pagination = {
          count: @pagy.items,
          total_count: @pagy.count,
          page: @pagy.page,
          prev_page: @pagy.prev,
          next_page: @pagy.next
        }

        render json: { recipes: Recipe.from(@records, :recipes).to_json_list, pagination: }
      end

      def suggest
        suggestion = Suggestion::CreateService.call(suggest_params)

        if suggestion.invalid? || suggestion.errors.any?
          render json: { errors: suggestion.errors }, status: :unprocessable_entity
        else
          render json: { suggestion: }, status: :ok
        end
      end

      private

      def recipes
        provided_sort_key = params[:sort_key]
        provided_sort_direction = params[:sort_direction]

        sort_key = SORT_KEYS.include?(provided_sort_key) ? provided_sort_key : DEFAULT_SORT_KEY
        sort_direction = if SORT_DIRECTIONS.include?(provided_sort_direction)
                           provided_sort_direction
                         else
                           DEFAULT_SORT_DIRECTION
                         end

        Recipe.order(sort_key.to_sym => sort_direction.to_sym)
      end

      def not_found
        raise ActionController::RoutingError, 'Not Found'
      end

      def suggest_params
        params.require(:suggestion).permit(:perfect_match_only, ingredients: %i[id quantity unit_id])
      end
    end
  end
end
