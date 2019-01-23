def factorial(num)
  raise InvalidArgument, 'negative input given' if n < 0

  return 1 if num == 0
  factorial(num - 1) * num
end

puts 1_000
factorial(1_000).to_s.size

puts 100_000
factorial(100_000).to_s.size
