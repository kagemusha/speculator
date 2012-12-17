class Util
#test comment: remove!

  def self.p(label, *msg)
    msgStr = msg.empty? ? "#{label}" : "#{label}: "+ msg.join(", ")
    Rails.logger.debug msgStr
  end

  def self.convert_float(str)
    return nil if !str or str.class != String
    str.to_f_f
  end


  def self.is_number?(i)
    true if Float(i) rescue false
  end

  def self.pret(expr, label="pret")
    Util.p label, expr
    expr
  end

end
