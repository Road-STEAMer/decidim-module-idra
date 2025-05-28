# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module Idra
    class Engine < ::Rails::Engine

      initializer "idra.add_routes" do |app|
        app.routes.append do
          resources :idra, only: [:index] do
            collection do
              post :search
            end
          end
        end
      end

      initializer "decidim_idra.add_cells_view_paths" do
        Cell::ViewModel.view_paths.unshift(File.expand_path("#{Decidim::Idra::Engine.root}/app/cells"))
      end
    end
  end
end
