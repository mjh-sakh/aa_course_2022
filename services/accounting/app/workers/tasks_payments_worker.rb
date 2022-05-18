# frozen_string_literal: true

class TasksPaymentsWorker
  include Sneakers::Worker

  MAX_RETRY = 5
  QUEUE_NAME = :tasks_processing_by_accounting

  from_queue(
    QUEUE_NAME,
    arguments: {
      'x-dead-letter-exchange' => "#{QUEUE_NAME}-retry"
    },
    routing_key: '#',
    exchange: 'aa_tasks_lifecycle',
    exchange_options: { durable: true },
    retry_max_times: MAX_RETRY,
    ack: true
  )

  def work_with_params(message, delivery_info, metadata)
    logger.info message
    logger.info delivery_info
    logger.info metadata

    message = parse(message)
    ::TasksPaymentProcessor.new(message).process!

    ack!
  end

  private

  def parse(message)
    JSON.parse(message).with_indifferent_access
  end
end
