# frozen_string_literal: true

module Api
  module V1
    class RecipesController < ApplicationController
      include Pagy::Backend
      
      def list; end

      def search; end

      def suggest; end
    end
  end
end
