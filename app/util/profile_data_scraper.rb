class ProfileDataScraper

  def self.add_data(stock)
    data_hash = Hash.new
    url = WsjDataMappings::symbol_url(stock.symbol, "company-people")
    page = Nokogiri::HTML(open url)
    stock.company_name = page.css("a#cr_name_id").text
    stock.description = page.css("#cr_company_desc").text
    stock.exch = page.css(".cr_quoteHeader abbr").to_s.upcase.include?("NYSE") ? "NYSE" : "NASD"
    page.css(".cr_data_field").each do |field|
      label = field.css(".data_lbl").text.strip
      val = field.css(".data_data").text.strip
      #pr "profdata", label, val
      data_hash[label] = val
    end
    stock.industry = data_hash["Industry"]
    stock.sector = data_hash["Sector"]
    stock.competitors = page.css("ul#competitors_Tab li a").collect {|item| item.content }
    stock.save
    data_hash
  end



end