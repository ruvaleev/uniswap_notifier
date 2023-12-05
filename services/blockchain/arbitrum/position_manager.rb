# frozen_string_literal: true

module Blockchain
  module Arbitrum
    class PositionManager < Base
      ABI_PATH = File.expand_path('./abis/position_manager_abi.json', __dir__)
      ADDRESS = '0xc36442b4a4522e871399cd717abdd847ab11fe88'
      EVENT_NAMES = %w[Collect DecreaseLiquidity IncreaseLiquidity].freeze
      NAME = 'NonfungiblePositionManager'

      def initialize
        super(ADDRESS)
      end

      def logs(*position_ids)
        events_datas = get_event_datas(*EVENT_NAMES)
        signatures_ids = get_signatures_ids(position_ids)
        result_logs = request_logs(events_datas.keys, signatures_ids.keys)

        parse_logs(result_logs, events_datas, signatures_ids, EVENT_NAMES)
      end

      private

      def get_event_datas(*event_names)
        event_names.to_h do |name|
          interface = abi.find { |func| func['name'] == name && func['type'] == 'event' }
          signed_name = sign_name(name, interface['inputs'])
          inputs = interface['inputs'].reject { |log| log['indexed'] }
          input_names = inputs.pluck('name')
          input_types = inputs.pluck('type')

          [signed_name, { name:, input_names:, input_types: }]
        end
      end

      def sign_name(name, inputs)
        name_to_sign = "#{name}(#{inputs.pluck('type').join(',')})"
        "0x#{Eth::Util.keccak256(name_to_sign).unpack1('H*')}"
      end

      def get_signatures_ids(ids)
        ids.to_h { |id| ["0x#{id.to_s(16).rjust(64, '0')}", id] }
      end

      def request_logs(signed_events, signed_ids)
        params = { address: contract.address, fromBlock: 'earliest', topics: [signed_events, signed_ids] }
        response = client.eth_get_logs(params)
        response['result']
      end

      def parse_logs(logs, events_datas, signatures_ids, event_names)
        logs.each.with_object({}) do |log, result|
          signed_event, signed_position_id = log['topics']
          position_id = signatures_ids[signed_position_id]
          result[position_id] ||= event_names.to_h { |name| [name, []] }
          position_data = result[position_id]
          event_data = events_datas[signed_event]

          position_data[event_data[:name]] << parse_log(log, event_data)
        end
      end

      def parse_log(log, event_data)
        log_data = Eth::Abi.decode(event_data[:input_types], log['data'])
        log_hash = log_data.map.with_index { |val, i| [event_data[:input_names][i], val] }.to_h
        log_hash['blockNumber'] = log['blockNumber'].to_i(16)
        log_hash
      end
    end
  end
end
