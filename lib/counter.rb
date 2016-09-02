module Counter
  @count = 0

  def self.increment
    @count += 1
  end

  def self.decrement
    @count -= 1
  end

  def self.reset
    @count = 0
  end
end