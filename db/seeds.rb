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
    when_started = DateTime.now
    when_started_str = "Started: #{when_started}"
    File.open(log_path, 'a') {|f| f << when_started_str }
    File.open(error_path, 'a') {|f| f << when_started_str }

    file = File.read(file_path)
    json_data = JSON.parse(file)

    record_count = json_data['products'].to_a.length

    File.open(log_path, 'a') {|f| f << "\n\nLoading..." }
    json_data['products'].each do |jd|
      begin
        created = Product.create!(jd)
        loaded_qty += 1
        File.open(log_path, 'a') {|f| f << "\n\n#{jd.inspect}" }
      rescue => e
        errored_qty += 1
        error_msg = "\n\n" + '='*80 + "\n== Error:#{e.message}"
        error_msg << "\n\n== Data:\n#{jd}"
        error_msg << "\n\n== Error Backtrace:\n#{e.backtrace}"
        File.open(error_path, 'a') {|f| f << error_msg }
      end
    end
  rescue => e
    errored_qty += 1
    File.open(error_path, 'a') {|f| f << "#{{error_message: e.message, error_backtrace: e.backtrace}.inspect}\n" }
  end
  File.open(log_path, 'a') { |f| f.write("\n\n#{loaded_qty} out of #{record_count} loaded.") }
  File.open(error_path, 'a') { |f| f.write("\n\n#{errored_qty} out of #{record_count} errored.") }

  File.open(log_path, 'a') { |f| f.write("\n\nWarning! Not all data loaded! See '#{error_path}'.") } if (loaded_qty < record_count)

  when_finished = DateTime.now
  when_finished_str = "\n\nFinished: #{when_finished}"
  when_duration = ((when_finished - when_started) * 24.0 * 60 * 60).to_f
  when_duration_str = "\nDuration: #{format("%.4f", when_duration)} seconds\n"

  File.open(log_path, 'a') {|f| f << when_finished_str }
  File.open(error_path, 'a') {|f| f << when_finished_str }
  File.open(log_path, 'a') {|f| f << when_duration_str }
  File.open(error_path, 'a') {|f| f << when_duration_str }
end

load_products