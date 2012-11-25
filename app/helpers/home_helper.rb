module HomeHelper

  def commod_calcs(data)
    Util.p "ccc", data.inspect
    last_chg = signed_pct_chg data[2], data[3]
    year_chg = signed_pct_chg data[2], data[4]
    [data[2], last_chg, year_chg, data[0], data[1]]
  end


  def signed_pct_chg(new_val, old_val)
    old_val = old_val.to_f_f if old_val.class == String
    new_val = new_val.to_f_f if new_val.class == String
    chg = 100*(new_val - old_val)/old_val
    Util.p "pct_chg (old,new,chg)", old_val, new_val, chg
    "#{chg>0 ? "+":""}#{"%.2f"%(chg)}%"
  end


end

