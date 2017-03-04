class String
  def camelize
    self.gsub(/_([a-z])/) { $1.upcase }
  end
end
