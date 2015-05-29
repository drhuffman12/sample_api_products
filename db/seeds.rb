# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'json'

def load_products
  file_path = 'db/products.json'
  log_path = file_path + '.log'
  error_path = file_path + '.err'
  errored_qty = 0
  loaded_qty = 0
  begin
    File.delete(log_path) if File.exists?(log_path)
    File.delete(error_path) if File.exists?(error_path)
    file = File.read(file_path)
    json_data = JSON.parse(file)
    json_data['products'].each do |jd|
      begin
        created = Product.create!(jd)
        loaded_qty += 1
        File.open(log_path, 'a') {|f| f << "#{jd.inspect}\n" }
      rescue => e
        errored_qty += 1
        File.open(error_path, 'a') {|f| f << "#{{data: jd, error_message: e.message, error_backtrace: e.backtrace}.inspect}\n" }
      end
    end
  rescue => e
    errored_qty += 1
    File.open(error_path, 'a') {|f| f << "#{{error_message: e.message, error_backtrace: e.backtrace}.inspect}\n" }
  end
  File.open(log_path, 'a') { |f| f.write("\n\n#{loaded_qty} loaded") } if loaded_qty > 0
  File.open(error_path, 'a') { |f| f.write("\n\n#{errored_qty} errored") } if errored_qty > 0
end

load_products