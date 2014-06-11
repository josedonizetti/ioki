class Env
  def initialize(parent)
    @parent = parent
    @env = {}
  end

  def contain?(key)
    return true if @env.has_key?(key)
    return @parent.contain?(key) if @parent
    false
  end

  def [](key)
    return @env[key] if @env.has_key?(key)
    @parent[key] if @parent
  end

  def []=(key, val)
    @env[key] = val
  end
end
