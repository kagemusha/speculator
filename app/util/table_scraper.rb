#!/usr/bin/env ruby
require 'nokogiri'
require 'open-uri'

class TableScraper

  def self.page_tables_to_arrays(page, table_selector="table")
    return nil if !page
    tables = get_tables_from_page page, table_selector
    tables.collect { |tbl| table_to_array tbl}

  end

  def self.table_to_array(table)
    table.search('tr').collect do |row|
      row.search('th, td').collect { |col| col.content ? col.content.strip : nil}
    end
  end

  def self.get_tables_from_page(page, table_selector="table")
    return nil if !page
    page.search table_selector
  end
end


