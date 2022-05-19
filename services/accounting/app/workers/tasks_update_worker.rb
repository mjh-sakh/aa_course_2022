# frozen_string_literal: true

class TasksUpdateWorker
  include Sneakers::Worker

  MAX_RETRY = 5
  QUEUE_NAME = :tasks_updates_by_accounting
  SUPPORTED_MESSAGE_VERSIONS = [2].freeze

  from_queue(
    QUEUE_NAME,
    arguments: {
      'x-dead-letter-exchange' => "#{QUEUE_NAME}-retry"
    },
    routing_key: '#',
    exchange: 'aa_tasks_stream',
    exchange_options: { durable: true },
    retry_max_times: MAX_RETRY,
    ack: true
  )

  def work_with_params(message, delivery_info, metadata)
    logger.info message
    logger.info delivery_info
    logger.info metadata

    message = parse(message)

    raise UnsupportedMessageError unless SUPPORTED_MESSAGE_VERSIONS.include? message['message_version']

    ::TaskUpserter.new(message).upsert!

    ack!

  rescue UnsupportedMessageError => e
    logger.error "Worker supports only message versions #{SUPPORTED_MESSAGE_VERSIONS.join(', ')}, but '#{message['message_version']}' come. Ack with no action."
    logger.error message
    ack!
  end

  private

  def parse(message)
    JSON.parse(message).with_indifferent_access
  end
end
