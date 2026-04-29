#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def main
  options = parse_options
  stdin = ARGF.file.instance_of?(IO)
  file_details = stdin ? parse_io_input : parse_file_input
  added_total_file_details = add_total_line(file_details) if file_details.size > 1
  adjusted_file_details = adjust_char_length(added_total_file_details || file_details, options, stdin)
  output_lines = create_output_lines(adjusted_file_details, options)
  output(output_lines)
end

def parse_options
  options = {}
  opt = OptionParser.new
  opt.on('-l')
  opt.on('-w')
  opt.on('-c')
  opt.parse!(ARGV, into: options)
  options = { l: true, w: true, c: true } unless options[:l] || options[:w] || options[:c]
  options
end

def create_file_detail(line_count, word_count, byte_count, file_name, directory)
  {
    line_count: line_count,
    word_count: word_count,
    byte_count: byte_count,
    file_name: file_name,
    directory: directory
  }
end

def parse_io_input
  lines = ARGF.readlines
  return [create_file_detail(0, 0, 0, '', false)] if lines.empty?

  line_count = word_count = byte_count = 0
  lines.each do |line|
    line_count += 1
    word_count += line.split(' ').size
    byte_count += line.bytesize
  end

  [create_file_detail(line_count, word_count, byte_count, '', false)]
end

def parse_file_input
  file_details = []
  loop do
    break if ARGF.closed?

    if File.directory?(ARGF.file) || File.empty?(ARGF.filename)
      file_details << create_file_detail(0, 0, 0, ARGF.filename, File.directory?(ARGF.file))
      ARGF.close
      next
    end

    line_count = word_count = byte_count = 0
    ARGF.each do |line|
      line_count += 1 if line[-1] == "\n"
      word_count += line.split(' ').size
      byte_count += line.bytesize
      break if ARGF.eof?
    end
    file_details << create_file_detail(line_count, word_count, byte_count, ARGF.filename, false)
    ARGF.close
  end
  file_details
end

def add_total_line(file_details)
  total_line_count = file_details.flat_map { _1.values_at(:line_count) }.sum
  total_word_count = file_details.flat_map { _1.values_at(:word_count) }.sum
  total_byte_count = file_details.flat_map { _1.values_at(:byte_count) }.sum

  file_details << create_file_detail(total_line_count, total_word_count, total_byte_count, '合計', false)
end

def adjust_char_length(file_details, options, stdin)
  selectors = create_char_length_selectors(file_details, options)
  max_length = file_details.flat_map { _1.values_at(*selectors) }.map { _1.to_s.length }.max
  max_length = 7 if max_length < 7 && (file_details.any? { _1[:directory] } || (stdin && options.values_at(*%i[l w c]).count(true) > 1))

  file_details.each do |detail|
    detail[:line_count] = detail[:line_count].to_s.rjust(max_length)
    detail[:word_count] = detail[:word_count].to_s.rjust(max_length)
    detail[:byte_count] = detail[:byte_count].to_s.rjust(max_length)
  end
end

def create_char_length_selectors(file_details, options)
  if file_details.size > 1 || (options.values_at(*%i[l w c]).count(true) > 1)
    %i[line_count word_count byte_count]
  else
    { l: :line_count, w: :word_count, c: :byte_count }.values_at(*options.filter { _1 }.keys)
  end
end

def create_output_lines(adjusted_file_details, options)
  output_lines = []
  adjusted_file_details.each do |detail|
    line = []
    line << detail[:line_count] if options[:l]
    line << detail[:word_count] if options[:w]
    line << detail[:byte_count] if options[:c]
    line << detail[:file_name]
    output_lines << line
    output_lines << ["wc: #{detail[:file_name]}: ディレクトリです"] if detail[:directory]
  end
  output_lines
end

def output(lines)
  lines.each { |line| puts line.join(' ') }
end

main
