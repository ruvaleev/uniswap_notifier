# frozen_string_literal: true

RSpec.shared_examples 'raises proper error' do |error_class|
  it "raises #{error_class}" do
    expect { subject }.to raise_error(error_class)
  end
end
