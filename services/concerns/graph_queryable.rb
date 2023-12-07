# frozen_string_literal: true

module GraphQueryable
  private

  def api_service
    @api_service ||= Graphs::RevertFinance.new
  end
end
