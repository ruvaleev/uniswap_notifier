# frozen_string_literal: true

def rand_blockchain_address(nonce = rand(10))
  "0x2a5e87c9312fb29aed5c179e456625d79015290#{nonce}"
end
