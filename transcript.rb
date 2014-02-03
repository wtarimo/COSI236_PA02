#Author: William Tarimo
#COSI236B - PA02
#2/2/2014


require_relative 'movie_data'

z = MovieData.new('ml-100k',:u1)

puts "z.rating(1,77): #{z.rating(1,77)}"
puts "z.movies(1): #{z.movies(1).first(10)}"
puts "z.viewers(77): #{z.viewers(77).first(10)}"
puts "z.predict(1,77): #{z.predict(1,77)}"

t = z.test(10)


puts "t.mean: #{t.mean}"
puts "t.stddev: #{t.stddev}"
puts "t.rms: #{t.rms}"
puts "t.to_a:"
print t.to_a