# frozen_string_literal: true

require_relative './config/environment'

require 'database_consistency'
result = DatabaseConsistency.run
exit result
