# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.
# frozen_string_literal: true

require_relative '../rails/app'

class ExampleComponent < ViewComponent::Base
  <<~ERB
    <%= @title %>
  ERB

  def initialize(title:)
    @title = title
  end
end

class ViewComponentController < ActionController::Base
  def index
    render(ExampleComponent.new(title: 'Hello World'))
  end
end

class DummyViewComponentInstrumentationClass
  include NewRelic::Agent::Instrumentation::ViewComponent
end

class ViewComponentInstrumentationTest < ActionDispatch::IntegrationTest
  include MultiverseHelpers
  setup_and_teardown_agent

  FAKE_CLASS = DummyViewComponentInstrumentationClass.new

  def test_metric_recorded
    get('/view_components')

    assert_metrics_recorded('View/view_component/view_component_instrumentation_test.rb/ExampleComponent')
  end

  def test_records_nothing_if_tracing_disabled
    NewRelic::Agent.disable_all_tracing do
      get('/view_components')
    end

    assert_metrics_not_recorded('View/view_component/view_component_instrumentation_test.rb/ExampleComponent')
  end

  def test_metric_path_falsey
    assert(FAKE_CLASS.metric_path(nil), 'component')
  end

  def test_metric_path_unknown_file_pattern
    assert(FAKE_CLASS.metric_path('nothing_to_see_here'), 'unknown')
  end
end
