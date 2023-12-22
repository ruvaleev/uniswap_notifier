# frozen_string_literal: true

module TelegramHelpers
  def send_message_response(chat_id: rand(1000), message_id: rand(1000))
    {
      ok: true,
      result: {
        message_id:,
        from: { id: 1_000_000_000, is_bot: true, first_name: 'bot_name', username: ENV.fetch('TG_BOT_USERNAME', nil) },
        chat: { id: chat_id, first_name: 'First', last_name: 'Last', username: 'username', type: 'private' },
        date: Time.current.to_i,
        text: 'Searching for positions...'
      }
    }.deep_stringify_keys
  end
end
