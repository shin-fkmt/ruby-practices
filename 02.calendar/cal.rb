#!/usr/bin/env ruby

require 'optparse'
require 'date'

year = Date.today.year
month = Date.today.month

params = {}
opt = OptionParser.new
opt.on('-y [VAL]', OptionParser::DecimalInteger) {|v| params[:y] = v }
opt.on('-m [VAL]', OptionParser::DecimalInteger) {|v| params[:m] = v }
opt.parse!(ARGV)

if !params[:y].nil?
  if (1970..2100).include?(params[:y])
    year = params[:y]
  else
    puts "year `#{params[:y]}' not in range 1970..2100"
    exit
  end
end

if !params[:m].nil?
  if (1..12).include?(params[:m])
    month = params[:m]
  else
    puts "month `#{params[:m]}' not in range 1..12"
    exit
  end
end

calendar = Array.new

one_week_template = {:Sun => '  ', :Mon => '  ', :Tue => '  ', :Wed => '  ', :Thu => '  ', :Fri => '  ', :Sat => '  '}
one_week = one_week_template.dup

last_day = Date.new(year, month, -1).day
(1..last_day).each do |day|
  date = Date.new(year, month, day)
  one_week[date.strftime('%a').to_sym] = day.to_s.rjust(2, ' ')

  if date.saturday? || day == last_day
    calendar.push(one_week.values)
    one_week = one_week_template.dup
  end
end

puts "#{month}月 #{year}".center(20, ' ')
puts "日 月 火 水 木 金 土"
calendar.each { |one_week| puts one_week.join(' ') }
