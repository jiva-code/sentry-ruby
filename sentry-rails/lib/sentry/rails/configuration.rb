require "sentry/rails/tracing/action_controller_subscriber"
require "sentry/rails/tracing/action_view_subscriber"
require "sentry/rails/tracing/active_record_subscriber"

module Sentry
  class Configuration
    attr_reader :rails

    add_post_initialization_callback do
      @rails = Sentry::Rails::Configuration.new
      @excluded_exceptions = @excluded_exceptions.concat(Sentry::Rails::IGNORE_DEFAULT)
    end
  end

  module Rails
    IGNORE_DEFAULT = [
      'AbstractController::ActionNotFound',
      'ActionController::BadRequest',
      'ActionController::InvalidAuthenticityToken',
      'ActionController::InvalidCrossOriginRequest',
      'ActionController::MethodNotAllowed',
      'ActionController::NotImplemented',
      'ActionController::ParameterMissing',
      'ActionController::RoutingError',
      'ActionController::UnknownAction',
      'ActionController::UnknownFormat',
      'ActionDispatch::Http::MimeNegotiation::InvalidType',
      'ActionController::UnknownHttpMethod',
      'ActionDispatch::Http::Parameters::ParseError',
      'ActiveRecord::RecordNotFound'
    ].freeze
    class Configuration
      # Rails catches exceptions in the ActionDispatch::ShowExceptions or
      # ActionDispatch::DebugExceptions middlewares, depending on the environment.
      # When `rails_report_rescued_exceptions` is true (it is by default), Sentry
      # will report exceptions even when they are rescued by these middlewares.
      attr_accessor :report_rescued_exceptions

      # Some adapters, like sidekiq, already have their own sentry integration.
      # In those cases, we should skip ActiveJob's reporting to avoid duplicated reports.
      attr_accessor :skippable_job_adapters

      attr_accessor :tracing_subscribers

      def initialize
        @report_rescued_exceptions = true
        @skippable_job_adapters = []
        @tracing_subscribers = Set.new([
          Sentry::Rails::Tracing::ActionControllerSubscriber,
          Sentry::Rails::Tracing::ActionViewSubscriber,
          Sentry::Rails::Tracing::ActiveRecordSubscriber
        ])
      end
    end
  end
end
