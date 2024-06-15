# frozen_string_literal: true

module Api
  module V1
    class IngredientsController < ApplicationController
      include Pagy::Backend

      rescue_from Pagy::OverflowError, :with => :not_found

      SORT_KEYS = %w[names].freeze
      SORT_DIRECTIONS = %w[asc desc].freeze

      DEFAULT_SORT_KEY = 'names'.freeze
      DEFAULT_SORT_DIRECTION = 'asc'.freeze

      def list
        @pagy, @records = pagy(ingredients)

        pagination = {
          count: @pagy.items,
          total_count: @pagy.count,
          page: @pagy.page,
          prev_page: @pagy.prev,
          next_page: @pagy.next
        }

        render json: { data: @records, pagination: }
      end

      def search
        search = params[:search] || ''

        @records = ingredients.search(params[:search])

        @pagy, @records = pagy(@records)

        pagination = {
          count: @pagy.items,
          total_count: @pagy.count,
          page: @pagy.page,
          prev_page: @pagy.prev,
          next_page: @pagy.next
        }

        render json: { data: @records, pagination: }
      end

      private

      def ingredients
        provided_sort_key = params[:sort_key]
        provided_sort_direction = params[:sort_direction]

        sort_key = SORT_KEYS.include?(provided_sort_key) ? provided_sort_key : DEFAULT_SORT_KEY
        sort_direction = SORT_DIRECTIONS.include?(provided_sort_direction) ? provided_sort_direction : DEFAULT_SORT_DIRECTION

        Ingredient.order(sort_key.to_sym => sort_direction.to_sym)
      end

      def not_found
        raise ActionController::RoutingError.new("Not Found")
      end
    end
  end
end
