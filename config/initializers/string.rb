class String

  def to_f_f
    neg = self.match /\((.*?)\)/
    float = self.gsub(/[^0-9.-]/, "").to_f
    #pr("Yen", debug_str, float) if debug_str.include? ""
    neg ? -float : float
  end

end