# frozen_string_literal: true
require 'bunny'

# rabbitMQ publisher
class Producer
  def publish(message, topic:)
    send_to_rabbitmq(message, topic)
  end

  private

  def send_to_rabbitmq(message, topic)
    connection = Bunny.new(ENV['AMQP_URL'])
    connection.start

    channel = connection.create_channel
    exchange = channel.exchange(topic, type: :topic, durable: true)
    exchange.publish(message.to_json)

    connection.close
  end
end
