# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module Idra
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Idra

      initializer "idra.add_routes" do |app|
        app.routes.append do
          get "/idra", to: "idra#index"
          post "/idra_create", to: "idra#create"
          get "/idra_update", to: "idra#update"
          post "/idra_delete", to: "idra#delete"
          get "/idra_modal_editor", to: "idra#modal_editor"
          get "/idra/datasets", to: "idra#datasets"
        end
      end

      initializer "decidim_idra.add_cells_view_paths" do
        Cell::ViewModel.view_paths.unshift(
          File.expand_path("#{Decidim::Idra::Engine.root}/app/cells")
        )
      end

      idra_url = "/idra"
      idra="Idra"

      Decidim.menu :menu do |menu|
          menu.add_item :root,
              idra,
              idra_url,
              position: 6,
              active: :exclusive
      end

      
    end
  end
end
