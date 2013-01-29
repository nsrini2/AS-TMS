module ArrayExtensions
  def shuffle
    self.sort_by{ rand }
  end
end

Array.__send__ :include, ArrayExtensions