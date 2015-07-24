class Player
	@@player_count = 0
	attr_accessor :name, :setter, :team, :color, :alt_color, :wins, :loss, :draw

	def initialize
		@@player_count += 1
		@name = "Player#{@@player_count}"
		@setter = "$"
		@team = []
		@color = :white
		@alt_color = :white
		@wins = @loss = @draw = 0
	end

	def summary_string
		"#{@name} | Wins: #{@wins} | Loss: #{@loss} | Draw: #{@draw}"
	end

	def set_stats(stats_hash)
		stats_hash.each do |variable, value|
			self.send("#{variable}=", value) if self.instance_variables.include?("@#{variable.to_s}".to_sym)
		end
		self
	end
end