# frozen_string_literal: true

class DailyReportWorker
  include Sneakers::Worker
  class DailyReportWasNotCompleted < StandardError; end

  MAX_RETRY = 5
  QUEUE_NAME = :accounting_daily_report

  from_queue(
    QUEUE_NAME,
    arguments: {
      'x-dead-letter-exchange' => "#{QUEUE_NAME}-retry"
    },
    routing_key: '#',
    exchange: 'aa_accounting_lifecycle',
    exchange_options: { durable: true },
    retry_max_times: MAX_RETRY,
    ack: true
  )

  def work_with_params(message, _delivery_info, _metadata)
    logger.info message

    command = parse(message)['command']
    DayPaymentProcessor.new.process! if command == 'start'
    ack!

  rescue StandardError
    logger.error "Daily report was not generated properly."
    logger.error [DailyReportWasNotCompleted, $!.to_s, $!.backtrace]
  end

  private

  def parse(message)
    JSON.parse(message).with_indifferent_access
  end
end
