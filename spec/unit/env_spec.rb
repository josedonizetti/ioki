require 'spec_helper'

describe Env do
  it "should hold variables" do
    parent = nil
    env = Env.new(parent)
    env[:x] = "x"

    expect(env.contain? :x).to eq(true)
    expect(env[:x]).to eq("x")
  end

  it "should try parent whenever it exist" do
    parent = Env.new(nil)
    env = Env.new(parent)

    parent[:a] = "a"
    env[:x] = "x"

    expect(env.contain? :x).to eq(true)
    expect(env[:x]).to eq("x")

    expect(env.contain? :a).to eq(true)
    expect(env[:a]).to eq("a")

    expect(env.contain? :a).to eq(true)
    expect(parent[:a]).to eq("a")

    expect(parent.contain? :x).to eq(false)
    expect(parent[:x]).to eq(nil)
  end

  it "should allow override of variables" do
    parent = Env.new(nil)
    env = Env.new(parent)

    parent[:x] = "x_parent"
    parent[:a] = "a_parent"
    env[:x] = "x_child"

    expect(parent.contain? :a).to eq(true)
    expect(parent[:a]).to eq("a_parent")

    expect(parent.contain? :x).to eq(true)
    expect(parent[:x]).to eq("x_parent")

    expect(env.contain? :x).to eq(true)
    expect(env[:x]).to eq("x_child")

    expect(env.contain? :a).to eq(true)
    expect(env[:a]).to eq("a_parent")
  end
end
