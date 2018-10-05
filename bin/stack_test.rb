def factorial(n)
  raise InvalidArgument, "negative input given" if n < 0

  return 1 if n == 0
  return factorial(n - 1) * n
end

puts 1_000
factorial(1_000).to_s.size

puts 100_000
factorial(100_000).to_s.size
