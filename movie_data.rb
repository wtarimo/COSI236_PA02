#Author: William Tarimo
#COSI236B - PA02
#1/23/2014


require 'pathname'
require_relative 'movie_test'


class MovieData
	attr_accessor :training_file, :test_file, :movieRatings, :users, :views

	def initialize(path,pair=nil)
		folder = Pathname.new(path)
		if folder.directory?
			@movieRatings = Hash.new { |hash, key| hash[key] = [0,0] } #hash[movie_id] = [totalRates, sumRates]
			@users = Hash.new { |hash, key| hash[key] = [] } #hash[user_id] = [movie_id, rating]
			@views = Hash.new { |hash, key| hash[key] = [] } #hash[movie_id] = [viewer_user_ids]
		
			@training_file = folder.join('u.data')
			if pair
				@training_file = folder.join("#{pair}.base")
				@test_file = folder.join("#{pair}.test")
			end
			load_data(@training_file)
		else
			puts "#{path} isn't a valid directory"
			exit
		end
	end

	def load_data(file)
		#Reads data from file and populates @movieRatings, @viewers and @users
		File.open(file,"r").each_line do |line|
			entry = line.split
			@movieRatings[entry[1].to_sym][0] += 1
			@movieRatings[entry[1].to_sym][1] += entry[2].to_i
			@users[entry[0].to_sym].push([entry[1],entry[2].to_i])
			@views[entry[1].to_sym].push(entry[0])
		end
	end

	def rating(u,m)
		#Returns the rating that user u gave movie m in the training set, 
		#and 0 if user u did not rate movie m
		raise "User not in Database" unless @users.has_key? u.to_s.to_sym
		rate = 0
		@users[u.to_s.to_sym].each {|id,rating| return rating if id==m.to_s}
		return rate

	end

	def predict(u,m)
		#returns a floating point number between 1.0 and 5.0 as an estimate of what user u would rate movie m
		viewedUsers = viewers(m).drop(1)
		return 3.0 unless viewedUsers.size > 0
		#print "viewedUsers: ",viewedUsers
		wRatings = []
		similarities = []
		viewedUsers.each {|user| similarities.push similarity(u,user)}
		#print "similarities: ",similarities
		#puts
		min = 0
		min = similarities.min if similarities.size>1
		scale = (similarities.max-min)/1.5
		viewedUsers.each {|user| wRatings.push(rating(user,m)*(similarity(u,user)-min).to_f/scale)}
		#print "wRatings: ",wRatings
		#puts
		scale = (wRatings.max - wRatings.min)/4.0
		wRatings2=[]
		wRatings.each {|rating| wRatings2.push(1.0+(rating-wRatings.min)/scale)}
		#print "wRatings2: ",wRatings2
		return wRatings2.instance_eval { reduce(:+) / size.to_f }
	end

	def movies(u)
		#returns the array of movies that user u has watched
		raise "User not in Database" unless @users.has_key? u.to_s.to_sym
		movies = []
		@users[u.to_s.to_sym].each {|id,rating| movies.push id}
		return movies

	end

	def viewers(m)
		#returns the array of users that have seen movie m
		@views[m.to_s.to_sym]
	end

	def test(k=nil)
		#runs the z.predict method on the first k ratings in the test set and returns a MovieTest object containing the results.
		#The parameter k is optional and if omitted, all of the tests will be run.
		raise 'Test Set not defined!' if @test_file.nil?
		predictions = []
		count = 0
		File.open(@test_file,"r").each_line do |line|
			entry = line.split
			entry[3] = predict(entry[0],entry[1])
			predictions.push(entry)
			count+=1
			break if (k and count >= k)
		end
		return MovieTest.new predictions
	end



	def similarity(user1,user2)
		#Generates a number which indicates the similarity in movie preference btn users 1 and 2
		#Higher numbers indicates greater similarity
		similarity = 0
		if @users.has_key? user1.to_s.to_sym and @users.has_key? user2.to_s.to_sym
			
			ratings1 = @users[user1.to_s.to_sym]
			ratings2 = @users[user2.to_s.to_sym]
			ids2 = []
			ratings2.each {|id,rating| ids2.push id}
			ratings1.each {|id,rating| similarity += 5 -(rating - ratings2[ids2.index id][1]).abs if ids2.include? id}
		else
			puts "User(s) not in database"
		end
		return similarity
	end

end



z = MovieData.new('ml-100k',:u1)
t = z.test()
puts t.mean
puts t.stddev
puts t.rms
#print t.to_a