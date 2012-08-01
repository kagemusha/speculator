class Market

  def self.last_open_time
    zone = ActiveSupport::TimeZone.new("Eastern Time (US & Canada)")
    nowET = Time.now.in_time_zone(zone)
    if nowET.sunday?
      return Time.now - nowET.hour.hours - nowET.min.minutes - 32.hours
    elsif nowET.saturday?
      return Time.now - nowET.hour.hours - nowET.min.minutes - 8.hours
    elsif nowET.hour >= 16
      return Time.now - (nowET.hour-16).hours - nowET.min.minutes
    elsif nowET.hour < 9
      if nowET.monday?
        return Time.now - nowET.hour.hours - nowET.min.minutes - 56.hours
      else
        return Time.now - (nowET.hour).hours - nowET.min.minutes - 8.hours
      end
    else
      Time.now
    end
  end

  def self.open?
    zone = ActiveSupport::TimeZone.new("Eastern Time (US & Canada)")
    nowET = Time.now.in_time_zone(zone)
    return false if nowET.sunday? or nowET.saturday?
    return false if nowET.hour < 9 and nowET.hour > 16 or (nowET.hour==9 and nowET.min < 30)
    return false if (nowET.month==1 and nowET.day==1) or (nowET.month==7 and nowET.day==4)
    return false if (nowET.month==11 and nowET.day==11) or (nowET.month==12 and nowET.day==25)
    true
  end



end