#!/usr/bin/env ruby
# frozen_string_literal: true

frames = ARGV[0].gsub(/X/, '10,0').split(',').map(&:to_i).each_slice(2).to_a

point = 0
(0..frames.size - 1).each do |i|
  if i > 8
    point += frames[i].sum
  elsif frames[i][0] == 10
    point += frames[i].sum + frames[i + 1].sum
    point += frames[i + 2][0] if frames[i + 1][0] == 10
  elsif frames[i].sum == 10
    point += frames[i].sum + frames[i + 1][0]
  else
    point += frames[i].sum
  end
end

puts point
