# frozen_string_literal: true
require 'spec_helper'

describe Pragma::Policy do
  it 'has a version number' do
    expect(Pragma::Policy::VERSION).not_to be nil
  end

  it 'does something useful' do
    expect(false).to eq(true)
  end
end
