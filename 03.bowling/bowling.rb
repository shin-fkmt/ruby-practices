#!/usr/bin/env ruby
# frozen_string_literal: true

frames = ARGV[0].gsub(/X/, '10,0').split(',').map(&:to_i).each_slice(2).to_a

point = (0..frames.size - 1).sum do |i|
  if i > 8
    frames[i].sum
  elsif frames[i][0] == 10
    frames[i].sum + frames[i + 1].sum + (frames[i + 1][0] == 10 ? frames[i + 2][0] : 0)
  elsif frames[i].sum == 10
    frames[i].sum + frames[i + 1][0]
  else
    frames[i].sum
  end
end

puts point
