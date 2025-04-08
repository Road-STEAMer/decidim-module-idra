# frozen_string_literal: true

# Calcoliamo il percorso base per il modulo
base_path = "/home/daniele/decidim0.29.1-idra/decidim-module-idra"

# Registriamo il percorso dei pacchetti e forziamo il caricamento per primo
Decidim::Webpacker.register_path("#{base_path}/app/packs", prepend: true)

# Registriamo anche gli entrypoints specifici per il modulo
Decidim::Webpacker.register_entrypoints(
  decidim_iframe: "#{base_path}/app/packs/entrypoints/decidim_iframe.scss"
)
