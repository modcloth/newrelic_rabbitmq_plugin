require 'uri'
require 'cgi'

require "newrelic_plugin"
require "faraday"
require "faraday_middleware"

module NewRelicRabbitMQPlugin
  VERSION = File.read(File.expand_path('../../VERSION', __FILE__)).chomp

  class Agent < NewRelic::Plugin::Agent::Base
    agent_guid "com.modcloth.newrelic_plugin.rabbitmq"
    agent_version ::NewRelicRabbitMQPlugin::VERSION
    agent_config_options :name, :uri
    agent_human_labels("RabbitMQ") do
      u = ::URI.parse(uri)
      name || "#{u.host}:#{u.port}"
    end

    def setup_metrics
      @messages_published = NewRelic::Processor::EpochCounter.new
      @messages_acked = NewRelic::Processor::EpochCounter.new
      @messages_delivered = NewRelic::Processor::EpochCounter.new
      @messages_confirmed = NewRelic::Processor::EpochCounter.new
      @messages_redelivered = NewRelic::Processor::EpochCounter.new
      @messages_noacked = NewRelic::Processor::EpochCounter.new
      @bytes_in = NewRelic::Processor::EpochCounter.new
      @bytes_out = NewRelic::Processor::EpochCounter.new
    end

    def poll_cycle
      response = conn.get("/api/overview")

      statistics = response.body

      report_metric "Queues/Queued", "Messages", statistics.fetch("queue_totals").fetch("messages")
      report_metric "Queues/Ready", "Messages", statistics.fetch("queue_totals").fetch("messages_ready")
      report_metric "Queues/Unacknowledged", "Messages", statistics.fetch("queue_totals").fetch("messages_unacknowledged")

      statistics.fetch("object_totals").each do |key, value|
        report_metric "Objects/#{key.capitalize}", key, value
      end

      report_metric "Messages/Publish", "Messages/Second", @messages_published.process(statistics.fetch("message_stats")["publish"])
      report_metric "Messages/Ack", "Messages/Second", @messages_acked.process(statistics.fetch("message_stats")["ack"])
      report_metric "Messages/Deliver", "Messages/Second", @messages_delivered.process(statistics.fetch("message_stats")["deliver_get"])
      report_metric "Messages/Confirm", "Messages/Second", @messages_confirmed.process(statistics.fetch("message_stats")["confirm"])
      report_metric "Messages/Redeliver", "Messages/Second", @messages_redelivered.process(statistics.fetch("message_stats")["redeliver"])
      report_metric "Messages/NoAck", "Messages/Second", @messages_noacked.process(statistics.fetch("message_stats")["get_no_ack"])

      response = conn.get("/api/nodes")
      statistics = response.body
      statistics.each do |node|
        report_metric "Node/MemoryUsage/#{node.fetch("name")}", "Percentage", (node.fetch("mem_used").to_f / node.fetch("mem_limit"))
        report_metric "Node/ProcUsage/#{node.fetch("name")}", "Percentage", (node.fetch("proc_used").to_f / node.fetch("proc_total"))
        report_metric "Node/FdUsage/#{node.fetch("name")}", "Percentage", (node.fetch("fd_used").to_f / node.fetch("fd_total"))
        report_metric "Node/Type/#{node.fetch("name")}", "Type", node.fetch("type")
        report_metric "Node/Running/#{node.fetch("name")}", "Running", node.fetch("running") ? 1 : 0
      end
    end

    def conn
      @conn ||= Faraday.new(url: uri) do |conn|
        u = ::URI.parse(uri)
        conn.basic_auth(u.user, u.password)

        conn.response :json, :content_type => /\bjson$/

        conn.use Faraday::Response::RaiseError
        conn.adapter Faraday.default_adapter
      end
    end
  end

  def self.run
    NewRelic::Plugin::Config.config.agents.keys.each do |agent|
      NewRelic::Plugin::Setup.install_agent agent, self
    end

    NewRelic::Plugin::Run.setup_and_run
  end
end
