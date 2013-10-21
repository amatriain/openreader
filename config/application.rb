require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

##
# Main module of the Feedbunch application. Most classes will be namespaced inside
# this module.

module Feedbunch

  ##
  # Main class of the Feedbunch application. Global settings are set here.

  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Fall back to the default locale ("en" if config.i18n.default_locale is not configured)
    # if the locale sent by the user does not exist
    config.i18n.fallbacks = true

    # Rails generators generate FactoryGirl factories instead of fixtures
    config.generators do |g|
      g.fixture_replacement :factory_girl
    end

    # Add "target" html attribute to the whitelist when using the sanitize helpers.
    # This is necessary because otherwise all "target" attributes are filtered out, which means that the app cannot
    # create links with target="_blank" that open in a new tab.
    # We really want links in feed entries to open in a new tab!
    config.action_view.sanitized_allowed_attributes = %w(target)

    # Most devise views use the devise layout except "edit_registration", which uses the application layout
    config.to_prepare do
      Devise::RegistrationsController.layout proc{|controller| user_signed_in? ? 'application' : 'devise'}
    end
  end
end
