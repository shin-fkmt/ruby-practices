#!/usr/bin/env ruby

(1..20).each do |count|
  if count % 15 == 0
    message = "FizzBuzz"
  elsif count % 5 == 0
    message = "Buzz"
  elsif count % 3 == 0
    message = "Fizz"
  else
    message = count.to_s
  end
  puts message
end
