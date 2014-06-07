require 'spec_helper'

describe Ioki::Emitter do
  it "should compile basic integers" do
    integers = [0, 1, -1, 10, -10, 2736, -2736, 536870911, -536870912]
    integers.each do |integer|
      got = compile_and_execute_test(integer)
      expect(got).to eq(integer.to_s)
    end
  end
end
