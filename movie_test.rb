#Author: William Tarimo
#COSI236B - PA02
#1/23/2014

class MovieTest
	attr_accessor :file, :movies, :users

	def initialize(file_path)
		if File.exists? file_path and File.file? file_path
			@file = file_path
			@movies = Hash.new { |hash, key| hash[key] = [0,0] } #hash[movie_id] = [totalRates, sumRates]
			@users = Hash.new { |hash, key| hash[key] = [] } #hash[user_id] = [movie_id, rating]
		else
			puts "#{file_path} doesn't exist or isn't a file!"
			exit
		end
	end

	def load_data
		#Reads data from @file and populates @movies and @users
		File.open(@file,"r").each_line do |line|
			entry = line.split
			@movies[entry[1].to_sym][0] += 1
			@movies[entry[1].to_sym][1] += entry[2].to_i
			@users[entry[0].to_sym].push([entry[1],entry[2].to_i])
		end
	
	end

	def popularity(movie_id)
		#Returns a rank out of all movie ids that indicates the popularity (higher number means more popular)
		#Polularity is measured by sum of ratings
		index = popularity_list.index movie_id.to_s.to_sym
		if index
			return @movies.keys.size - index
		else
			puts "Movie ID not database!"
			return nil
		end
	end

	def popularity_list
		#Generates and returns a list of all movie_id's ordered by decreasing popularity
		#Movies are sorted by first the sum of ratings, then the number of ratings
		movie_ids = @movies.keys
		movie_ids.sort_by{|key| [@movies[key][1],@movies[key][0]]}.reverse
	
	end

	def similarity(user1,user2)
		#Generates a number which indicates the similarity in movie preference btn users 1 and 2
		#Higher numbers indicates greater similarity
		if @users.has_key? user1.to_s.to_sym and @users.has_key? user2.to_s.to_sym
			similarity = 0
			ratings1 = @users[user1.to_s.to_sym]
			ratings2 = @users[user2.to_s.to_sym]
			ids2 = []
			ratings2.each {|id,rating| ids2.push id}
			ratings1.each {|id,rating| similarity += 5 -(rating - ratings2[ids2.index id][1]).abs if ids2.include? id}
			return similarity
		else
			puts "User(s) not in database"
			return nil
		end
	end

	def most_similar(u)
		#Returns a list of users whose tastes are most similar to the tastes of user u
		user_ids = @users.keys
		user_ids.sort_by {|id| [similarity(u,id)]}.reverse.drop(1) #The 1st is always u
	end

end