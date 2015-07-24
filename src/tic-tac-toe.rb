require_relative "game"

#          Need to test methods other than begin and play with rspec

class TicTacToe < Game

	def initialize
		@to_win = 3
		@size = 3
		super(@size, @size, true)
		@player1.set_stats(setter: "X", color: :yellow, alt_color: :blue)
		@player2.set_stats(setter: "O", color: :green, alt_color: :red)
		@main_menu << ["Play Game", "Select Characters", "Name Players", "Adjust Size: #{@size}", "Adjust Row to Win: #{@to_win}"]
		@main_menu.show
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

	def begin
		quit = false
		while not quit
			@main_menu.show
			input = @main_menu.use
			case input
			when 'q' then exit
			when 'b' then quit = true
			#when 'l' then load
			when "\e[C" then adjust_option(:right)
			when "\e[D" then adjust_option(:left)
			when " " then menu_selection
			when "\r" then menu_selection
			end
		end
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
			quit = true if @board.empty_spaces == 0 || @winner != nil
		end
		reset
		#play
	end

	def adjust_option(direction)
		if @main_menu.current_option == 3 || @main_menu.current_option == 4
			adjust_size(direction) if @main_menu.current_option == 3
			adjust_win(direction) if @main_menu.current_option == 4
		end
	end

	def adjust_size(direction)
		@size += 1 if direction == :right
		@size -= 1 if direction == :left
		@size = 5 if @size > 5
		@size = 2 if @size < 2
		@size = @to_win if @size < @to_win
		resize
		@main_menu.change_option_label(3, "Adjust Size: #{@size}")
	end

	def adjust_win(direction)
		@to_win += 1 if direction == :right
		@to_win -= 1 if direction == :left
		@to_win = @size if @to_win > @size
		@to_win = 2 if @to_win < 2
		@main_menu.change_option_label(4, "Adjust Row to Win: #{@to_win}")
	end

	def menu_selection
		case @main_menu.current_option
		when 0 then play
		when 1 then select_characters
		when 2 then name_players
		end
	end

	def select_characters
		@player1.setter = @characters.select_a_character
		@player2.setter = @characters.select_a_character
	end

	def name_players

	end

	def resize
		@board.resize(@size, @size)
		@display = @board.full(:light_magenta)
	end

	def reset
		@board.reset
		@display = @board.full(:light_magenta)
		@winner = nil
	end

	def set_piece
		space = @board.current_space
		if space.empty?
			space.alt_color = @turn.alt_color
			space.set(value: @turn.setter, color: @turn.color)
			winner = @board.in_a_row(@to_win)
			@winner = winner if winner
			change_turn
		end
	end
end

t = TicTacToe.new
t.begin