require_relative "board"
require_relative "../lib/formatter"

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

class Game

	def initialize(rows, columns, interactive=true)
		@board = Board.new(rows, columns, interactive)
		@display = @board.full(:light_magenta)
		@player1 = @turn = Player.new
		@player2 = Player.new
	end

	def change_turn
		@turn = @turn.object_id === @player1.object_id ? @player2 : @player1
	end

	def save

	end
end

class TicTacToe < Game

	def initialize
		super(3, 3, true)
		@player1.set_stats(setter: "X", color: :yellow, alt_color: :blue)
		@player2.set_stats(setter: "O", color: :green, alt_color: :red)
	end

	def update_display
		board_loc = @display.child_loc(@board.format)
		@display.set_direction([board_loc[2],0], [0,1], value: :" ")
		@display.set_direction([2,0], [0,1], value: :" ")
		@display.set_direction([3,0], [0,1], value: :" ")
		@display.insert_string([2,0], value: @player1.summary_string, background: :blue)
		@display.insert_string([4,0], value: @player2.summary_string, background: :green)
		@display.insert_string([board_loc[2]+1,0], value: "#{@turn.name} it is your turn to place a #{@turn.setter}", color: :white, background: :red)
	end

	def play
		quit = false
		while not quit
			update_display
			puts @display.to_s
			input = @board.use
			case input
			when 'q' then exit
			when 'b' then quit = true
			when 's' then save
			when "\r" then set_piece
			when " " then set_piece
			end
		end
	end

	def set_piece
		space = @board.current_space
		if space.empty?
			space.alt_color = @turn.alt_color
			space.set(value: @turn.setter, color: @turn.color)
			change_turn
			#@board.format.update
		end
	end
end

t = TicTacToe.new
t.play