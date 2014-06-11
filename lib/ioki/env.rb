class Env
  def initialize(parent)
    @parent = parent
    @variables = {}
    @lambdas = {}
  end

  def get_variable(key)
    return @variables[key] if @variables.has_key?(key)
    @parent.get_variable(key) if @parent
  end

  def add_variable(key, val)
    @variables[key] = val
  end

  def variable?(key)
    return true if @variables.has_key?(key)
    return @parent.variable?(key) if @parent
    false
  end

  def lambda?(key)
    return true if @lambdas.has_key?(key)
    return @parent.lambda?(key) if @parent
    false
  end

  def get_lambda(key)
    return @lambdas[key] if @lambdas.has_key?(key)
    @parent.get_lambda(key) if @parent
  end

  def add_lambda(key, val)
    @lambdas[key] = val
  end
end
