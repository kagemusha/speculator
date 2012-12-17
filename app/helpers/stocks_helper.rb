module StocksHelper

  def format_stat(val, precision=1)
    return "" if !val
    units = ""
    if val.abs > 1000
      units = "B"
      val /= 1000
    end
    "#{number_with_precision val, :precision=>precision}#{units}"
  end

end
