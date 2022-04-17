# hacker rank

require 'set'
require 'json'
require 'stringio'

def gridSearch(grid, pattern)
  # Write your code here
  (0..grid.length).each do |i|
    break unless grid.length - i >= pattern.length

    k = 0
    substring_ixs = Set.new
    pattern.each do |pattern_line|
      next_ixs = find_substring_start_ixs(grid[i + k], pattern_line)
      if k.zero?
        substring_ixs = next_ixs
      else
        substring_ixs &= next_ixs
      end
      break if substring_ixs.empty?

      k += 1
    end
    next if substring_ixs.empty?

    return 'YES'
  end
  'NO'
end

def find_substring_start_ixs(line, substring)
  (0..line.length - substring.length).select { |i| line[i, substring.length] == substring }.to_set
end


module Kernel
  def suppress_warnings
    original_verbosity = $VERBOSE
    $VERBOSE = nil
    result = yield
    $VERBOSE = original_verbosity
    return result
  end
end

ARGV << 'test_case_8.txt'
t = gets.strip.to_i

suppress_warnings do
  t.times do |t_itr|
    first_multiple_input = gets.rstrip.split

    R = first_multiple_input[0].to_i

    C = first_multiple_input[1].to_i

    G = Array.new(R)

    R.times do |i|
      G_item = gets.chomp

      G[i] = G_item
    end

    second_multiple_input = gets.rstrip.split

    r = second_multiple_input[0].to_i

    c = second_multiple_input[1].to_i

    P = Array.new(r)

    r.times do |i|
      P_item = gets.chomp

      P[i] = P_item
    end

    result = gridSearch G, P

    puts "#{t_itr}: #{result}"
  end
end

