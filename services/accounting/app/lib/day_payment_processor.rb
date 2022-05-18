class DayPaymentProcessor
  def process!
    process_time = Time.now.utc
    log = TransactionLogRecord.where('record_time < ?', process_time)

    payment_items = []
    User.where(status: :active).each do |user|
      user_balance = log.where(user_id: user.id).pluck(:amount).sum
      next unless user_balance.positive?

      payment_items << {
        user_id: user.id,
        event_time: process_time,
        amount: -user_balance, # negative
        record_type: :payment,
        note: 'Payment made as positive balance'
      }
    end

    ActiveRecord::Base.transaction do
      payment_items.each do |payment_data|
        TransactionLogRecord.create(**payment_data, record_time: Time.now)
        User.find(payment_data[:user_id]).update(balance: 0)
      end
    end
  end
end
