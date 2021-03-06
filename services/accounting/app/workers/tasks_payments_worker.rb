# frozen_string_literal: true

class TasksPaymentsWorker
  include Sneakers::Worker

  class UnsupportedMessageError < StandardError; end
  class BusinessEventWasNotProcessed < StandardError; end

  MAX_RETRY = 5
  QUEUE_NAME = :tasks_processing_by_accounting
  SUPPORTED_MESSAGE_VERSIONS = [2].freeze

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

    raise UnsupportedMessageError unless SUPPORTED_MESSAGE_VERSIONS.include? message['message_version']

    TasksPaymentProcessor.new(message).process!
    ack!

  rescue UnsupportedMessageError
    logger.error "Worker supports only message versions #{SUPPORTED_MESSAGE_VERSIONS.join(', ')}, but '#{message['message_version']}' come. Ack with no action."
    logger.error message
    logger.error [UnsupportedMessageError, $!.to_s, $!.backtrace]
    ack!
  rescue StandardError
    logger.error "BE was not processed properly."
    logger.error message
    logger.error [BusinessEventWasNotProcessed, $!.to_s, $!.backtrace]
    reject!
  end

  private

  def parse(message)
    JSON.parse(message).with_indifferent_access
  end
end
