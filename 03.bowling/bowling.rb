#!/usr/bin/env ruby
# frozen_string_literal: true

frames = ARGV[0]
         .gsub(/X/, '10,0')
         .split(',')
         .map(&:to_i)
         .each_slice(2)
         .to_a

point = (0..frames.size - 1).sum do |i|
  current_frame = frames[i]
  next_frame = frames[i + 1]
  after_next_frame = frames[i + 2]

  if i > 8
    current_frame.sum
  elsif current_frame[0] == 10
    current_frame.sum + next_frame.sum + (next_frame[0] == 10 ? after_next_frame[0] : 0)
  elsif current_frame.sum == 10
    current_frame.sum + next_frame[0]
  else
    current_frame.sum
  end
end

puts point
