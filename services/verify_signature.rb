# frozen_string_literal: true

class VerifySignature
  def call(address:, message:, signature:, chain_id:)
    address.casecmp?(recovered_address(message, signature, chain_id))
  rescue Eth::Signature::SignatureError, Eth::Chain::ReplayProtectionError
    false
  end

  private

  def recovered_address(message, signature, chain_id)
    Eth::Util.public_key_to_address(
      Eth::Signature.personal_recover(message, signature, chain_id)
    ).to_s
  end
end
