require_relative "config/environment"
require 'sneakers'
require 'sneakers/handlers/maxretry'
require 'bunny'

rabbitmq_connection = Bunny.new(ENV['AMQP_URL'])

Sneakers.configure(
  connection: rabbitmq_connection,
  handler: Sneakers::Handlers::Maxretry,
  workers: Integer(ENV['SNEAKERS_BEACONS_MQ_WORKER_COUNT'] || 1),
  threads: Integer(ENV['SNEAKERS_BEACONS_MQ_THREAD_COUNT'] || 1),
  prefetch: Integer(ENV['SNEAKERS_BEACONS_MQ_THREAD_COUNT'] || 1),
  exchange_options: {
    type: :topic,
    durable: false,
    auto_delete: false
  }
)

require_relative 'app/workers/users_update_worker'
require_relative 'app/workers/tasks_payments_worker'
require_relative 'app/workers/tasks_update_worker'
require_relative 'app/workers/daily_report_worker'
