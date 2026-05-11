#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

FIXED_ITEM_SIZE = 7

def main
  options = parse_options
  file_details = ARGV.empty? ? parse_stdin_input : parse_file_input

  exit if file_details.empty?

  if file_details.size > 1
    total_line_count = file_details.map { _1[:line_count] }.sum
    total_word_count = file_details.map { _1[:word_count] }.sum
    total_byte_count = file_details.map { _1[:byte_count] }.sum
    file_details << create_file_detail(total_line_count, total_word_count, total_byte_count, '合計', false)
  end

  puts create_output_lines(file_details, options)
end

def parse_options
  options = {}
  opt = OptionParser.new
  opt.on('-l')
  opt.on('-w')
  opt.on('-c')
  opt.parse!(ARGV, into: options)
  options = { l: true, w: true, c: true } if options.count.zero?
  options
end

def parse_stdin_input
  buf = ARGF.read
  return [create_file_detail(0, 0, 0, '', false)] if buf.empty?

  counts = calculate_count(buf)
  [create_file_detail(counts[:line_count], counts[:word_count], counts[:byte_count], '', false)]
end

def parse_file_input
  file_details = []
  ARGV.each do |filename|
    next unless File.exist?(filename)
    next if filename[0] == '-'

    if File.directory?(filename) || File.empty?(filename)
      file_details << create_file_detail(0, 0, 0, filename, File.directory?(filename))
      next
    end

    counts = calculate_count(File.read(filename))
    file_details << create_file_detail(counts[:line_count], counts[:word_count], counts[:byte_count], filename, false)
  end
  file_details
end

def calculate_count(buf)
  {
    line_count: buf.count("\n"),
    word_count: buf.split(' ').count,
    byte_count: buf.bytesize
  }
end

def create_file_detail(line_count, word_count, byte_count, filename, is_directory)
  {
    line_count: line_count,
    word_count: word_count,
    byte_count: byte_count,
    filename: filename,
    is_directory: is_directory
  }
end

def max_char_length(file_details, options)
  selectors = create_char_length_selectors(file_details, options)
  max_char_length = file_details.flat_map { _1.values_at(*selectors) }.map { _1.to_s.length }.max

  return max_char_length if max_char_length > FIXED_ITEM_SIZE
  return FIXED_ITEM_SIZE if file_details.any? { _1[:is_directory] }
  return FIXED_ITEM_SIZE if ARGV.empty? && options.values_at(*%i[l w c]).count(true) > 1

  max_char_length
end

def create_char_length_selectors(file_details, options)
  if file_details.size > 1 || (options.values_at(*%i[l w c]).count(true) > 1)
    %i[line_count word_count byte_count]
  else
    { l: :line_count, w: :word_count, c: :byte_count }.values_at(*options.keys)
  end
end

def create_output_lines(file_details, options)
  output_lines = []
  max_char_length = max_char_length(file_details, options)
  file_details.each do |detail|
    line = []
    line << detail[:line_count].to_s.rjust(max_char_length) if options[:l]
    line << detail[:word_count].to_s.rjust(max_char_length) if options[:w]
    line << detail[:byte_count].to_s.rjust(max_char_length) if options[:c]
    line << detail[:filename]
    output_lines << line
    output_lines << ["wc: #{detail[:filename]}: ディレクトリです"] if detail[:is_directory]
  end
  output_lines.map { |line| line.join(' ') }
end

main
