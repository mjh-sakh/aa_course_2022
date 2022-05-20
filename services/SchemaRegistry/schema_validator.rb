# frozen_string_literal: true

# use example for following message
# message = {first: 1, second: {two: 2}}
#
# scheme definition:
# def test_scheme
#   t :first # any value is good
#   @subject = t :second, Hash # switching to test content of sub-hash
#   t :two, Integer
#
# SchemeValidator.new(message, test_scheme).validate!
# => true
#

require_relative 'task_schemas'
require_relative 'auth_schemas'

class SchemaValidator

  def initialize(message, schema_name)
    @message = message
    @subject = @message
    begin
      @validator = method(schema_name.to_sym)
    rescue
      raise ArgumentError, 'No such schema.'
    end
  end

  # @raise KeyError, TypeError or ArgumentError
  def validate!
    @validator.call
    true
  end

  # @return false if fails
  def validate
    validate!

  rescue
    false
  end

  private

  # t for test
  def t(key, value_check = nil)
    message_value = @subject.fetch(key)
    case value_check
    when NilClass # not specified, passing
    when Class # type check
      raise TypeError, "Type #{value_check} != #{message_value.class} for '#{key}'" if !message_value.is_a? value_check
    when Proc # used only for optional type check
      raise ArgumentError, "Type is not #{message_value.class} or nil for '#{key}'" if value_check.call(message_value)
    when Method # special check
      raise ArgumentError, "Special check '#{value_check.name}' failed for '#{key}'" if value_check.call(message_value)
    else # value check
      raise ArgumentError, "Value #{value_check} != #{message_value} for '#{key}'" if message_value != value_check
    end

    return message_value
  end

  def optional(type)
    check = ->(type, value) { !value.is_a? type and !value.nil? }.curry
    check.call(type)
  end

  # https://stackoverflow.com/a/47511286/12488601
  def uuid?(uuid)
    uuid_regex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/
    !uuid_regex.match?(uuid.to_s.downcase)
  end

  # ---- schema definitions goes here ----
  include TaskSchemas
  include AuthSchemas

end
