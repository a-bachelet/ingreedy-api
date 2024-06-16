# frozen_string_literal: true

module Api
  module V1
    class RecipesController < ApplicationController
      include Pagy::Backend
      
      rescue_from Pagy::OverflowError, :with => :not_found

      SORT_KEYS = %w[name].freeze
      SORT_DIRECTIONS = %w[asc desc].freeze

      DEFAULT_SORT_KEY = 'name'.freeze
      DEFAULT_SORT_DIRECTION = 'asc'.freeze

      def list
        @pagy, @records = pagy(recipes)

        pagination = {
          count: @pagy.items,
          total_count: @pagy.count,
          page: @pagy.page,
          prev_page: @pagy.prev,
          next_page: @pagy.next
        }

        @records

        render json: { recipes: @records, pagination: }
      end

      def search; end

      def suggest; end

      private

      def recipes
        provided_sort_key = params[:sort_key]
        provided_sort_direction = params[:sort_direction]

        sort_key = SORT_KEYS.include?(provided_sort_key) ? provided_sort_key : DEFAULT_SORT_KEY
        sort_direction = SORT_DIRECTIONS.include?(provided_sort_direction) ? provided_sort_direction : DEFAULT_SORT_DIRECTION

        Recipe.order(sort_key.to_sym => sort_direction.to_sym)
      end

      def not_found
        raise ActionController::RoutingError.new("Not Found")
      end
    end
  end
end
