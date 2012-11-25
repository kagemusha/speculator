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

=begin
  def self.get_random_items(array, count)
   return array if array.length < count
   array = array.clone
   array.shuffle if array.respond_to?("shuffle")
   array[0,count]
 end
 
  def self.pct_chg(old_amt, new_amt)
    return 0.0 if old_amt == 0.0
    100.0 * ((new_amt - old_amt).to_f/old_amt.to_f)
  end

  def self.avg(total, count)
    return 0.0 if count == 0
    (total/count).to_f
  end
  
  def self.dataset_to_hash(dataset, key_field)
    hash = Hash.new
    dataset.each do |item|
      hash[item.read_attribute(key_field)] = item
    end
    hash
  end
  
  def self.extract_field_from_dataset(array_of_hashes, key_field)
    array = Array.new
    array_of_hashes.each do |hash|
      array << hash[key_field]
    end
    array
  end
  
    #substitute for update_all which seems to be having problems
    #e.g. 
    #Util.update_all_sql("predictions","status=#{Prediction::STATUS_CLOSED}", "question_id=#{id}")
  def self.update_all_sql(tables, updates, conditions=nil)
    sql = "update #{tables} set #{updates} "
    sql += " where #{conditions}" if conditions
    #Util.p("updt", sql)
    ActiveRecord::Base.connection.update(sql)
  end
    
  def self.sql_query(sql)
    #Util.p("sqqu", sql)
    ActiveRecord::Base.connection.select_all sql
  end

  def self.get_unique_records(records, field, limit)
    used = Array.new
    uniques = Array.new
    records.each do |record|
      key = record.attributes[field]
      if !used.include?(key)
        uniques << record
        return if uniques.length >= limit
        used << key
      end
    end
    uniques
  end
  def self.combine_date_time(date_string, time_string)
    Time.parse('2010/10/31 04:00 am')
    Util.p "dtstr: #{date_string} #{time_string}"
    Time.parse("#{date_string} #{time_string}")
  end
=end
end
