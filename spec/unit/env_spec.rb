require 'spec_helper'

describe Env do
  it "should hold variables" do
    parent = nil
    env = Env.new(parent)
    env.add_variable(:x, "x")

    expect(env.variable? :x).to eq(true)
    expect(env.get_variable(:x)).to eq("x")
  end

  it "should try parent whenever it exist" do
    parent = Env.new(nil)
    env = Env.new(parent)

    parent.add_variable(:a, "a")
    env.add_variable(:x, "x")

    expect(env.variable? :x).to eq(true)
    expect(env.get_variable(:x)).to eq("x")

    expect(env.variable? :a).to eq(true)
    expect(env.get_variable(:a)).to eq("a")

    expect(env.variable? :a).to eq(true)
    expect(parent.get_variable(:a)).to eq("a")

    expect(parent.variable? :x).to eq(false)
    expect(parent.get_variable(:x)).to eq(nil)
  end

  it "should allow override of variables" do
    parent = Env.new(nil)
    env = Env.new(parent)

    parent.add_variable(:x, "x_parent")
    parent.add_variable(:a, "a_parent")
    env.add_variable(:x, "x_child")

    expect(parent.variable? :a).to eq(true)
    expect(parent.get_variable(:a)).to eq("a_parent")

    expect(parent.variable? :x).to eq(true)
    expect(parent.get_variable(:x)).to eq("x_parent")

    expect(env.variable? :x).to eq(true)
    expect(env.get_variable(:x)).to eq("x_child")

    expect(env.variable? :a).to eq(true)
    expect(env.get_variable(:a)).to eq("a_parent")
  end

  it "should return false/nil for variables that don't exist" do
    parent = Env.new(nil)
    env = Env.new(parent)

    expect(parent.variable? :a).to eq(false)
    expect(parent.get_variable(:a)).to eq(nil)

    expect(parent.variable? :x).to eq(false)
    expect(parent.get_variable(:x)).to eq(nil)

    expect(env.variable? :x).to eq(false)
    expect(env.get_variable(:x)).to eq(nil)

    expect(env.variable? :a).to eq(false)
    expect(env.get_variable(:a)).to eq(nil)
  end

end
