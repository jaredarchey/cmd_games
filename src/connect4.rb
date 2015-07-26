require_relative "game"

class Connect4 < Game

	def initialize
		super(6, 7, "1D_R")
		@to_win = 4
		@player1.set_stats(setter: "0", color: :yellow, alt_color: :blue)
		@player2.set_stats(setter: "O", color: :green, alt_color: :red)
		@main_menu << ["Play Game", \
		               "Name Players", \
		               "Select Character"]
	end

	def update_display
		board_loc = super
		@display.set_direction([board_loc[2],0], [0,1], value: :" ")
		@display.set_direction([2,0], [0,1], value: :" ")
		@display.set_direction([3,0], [0,1], value: :" ")
		@display.insert_string([2,0], value: @player1.summary_string, background: :blue)
		@display.insert_string([4,0], value: @player2.summary_string, background: :green)
		@display.insert_string([board_loc[2]+1,0], value: "#{@turn.name} it is your turn to place a #{@turn.setter}", color: :white, background: :red)
	end

	def menu_selection
		case @main_menu.current_option
		when 0 then play
		when 1 then name_players
		when 2 then select_characters
		end
	end

	def select_space
		space = first_empty_space(@board.current_space(true))
		if space
			space.set(value: @turn.setter, color: @turn.color)
			@winner = @board.in_a_row(@to_win)
			change_turn
		end
	end

	def post_game
		if @winner == nil
			string = "Draw!!!"
		else
			string = @winner == @player1.setter ? "Congratulations #{@player1.name} you win!" : "Congratulations #{@player2.name} you win!!"
		end
		update_display
		board_loc = @display.child_loc(@board.format)
		@display.set_direction([board_loc[2]+1,0], [0,1], value: :" ", background: :light_magenta)
		@display.insert_string([board_loc[2]+1,0], value: string, background: :yellow, color: :red)
		@display.insert_string([board_loc[2]+3,0], value: "Play Again? y/n")
		puts @display.to_s
	end
end

#Connect4.new.begin