#Author: William Tarimo
#COSI236B - PA02
#1/23/2014

class MovieTest
	attr_accessor :predictions, :avgError

	def initialize(predictions)
		@predictions = predictions
		totalError = 0
		predictions.each do |p|
			totalError+=(p[2].to_f-p[3]).abs
		end
		@avgError = totalError/predictions.size.to_f
	end

	def mean
		#Returns the average predication error (which should be close to zero)
		return @avgError
	end

	def stddev
		#Returns the standard deviation of the error
		dev = 0
		@predictions.each do |p|
			dev += ((p[2].to_f-p[3]).abs-@avgError)**2
		end
		return Math.sqrt(dev/@predictions.size)
		
	end

	def rms
		#Returns the root mean square error of the prediction
		eSquared = 0
		@predictions.each do |p|
			eSquared += (p[2].to_f-p[3])**2
		end
		return Math.sqrt(eSquared/@predictions.size)
	end

	def to_a
		#Returns an array of the predictions in the form [u,m,r,p]. 
		return @predictions
	end
end