require 'yaml'
require_relative "board"
require_relative "player"
require_relative "menu"
require_relative "../lib/input_helper"
require_relative "../lib/formatter"
require_relative "character_selection"

=begin

				         	    A Game
	#############################################################
    1. Has instance variables which determine how a player wins
    2. Has a board size and types of board interaction
        1. 2D space selection
        2. 1D space selection only at a certain row OR column
        3. No space selection, takes string input
    3. Each player has a color, an alt_color, a team, and a setter
       which can also be a team member
    4. Begins at the main menu, by running #begin
        1. q immediately ends the program
        2. b returns to the previous display
        2. Add menu item labels by @main_menu << [labels]
        3. Run methods when an option is selected by #menu_selection
            * case @main_menu.current_option \ when 0 then ... ....
        4. Perform other actions like change a variable with the
           left and right arrow keys with #menu_commands(input)
            * case input \ when char then ... ...
        5. The play method begins the game
    5. Play begins by updating the display with #update_display
    6. It receives the user input through the @board.use
    	1. For games which use arrow keys a space is selected by
    	   highlighting the one you want and #select_space is called
    	   when "\r" or " " is hit
        2. For games where you guess a string a string is created
           with @board.use and sent to #handle_string when "\r" is hit
    7. The game ends when the board has no open spaces or @winner
       is not NilClass
    8. A post-game summary displays, it the user hits y play is called
       again, other wise the game loop exits and the main_menu exits
       returning to the top menu if there is one
    9. The board resets, the display is updated with the new board,
       @winner is set back to nil
	#############################################################

=end

class Game
	include FormatHelper
	include InputHelper

	def initialize(rows, columns, interactive=true)
		@board = Board.new(rows, columns, interactive)
		@display = @board.full(:light_magenta)
		@player1 = @turn = Player.new
		@player2 = Player.new
		@characters = Selection.new
		@main_menu = Menu.new(self.class.to_s)

		@winner = nil
	end

	def begin
		begin
			@main_menu.show
			input = @main_menu.use
			case input
			when 'q' then exit
			when 'l' then @main_menu.load(self.class.to_s)
			when " " then menu_selection
			when "\r" then menu_selection
			else menu_commands(input) 
			end
		end until input == 'b'
	end

	def menu_selection
	end

	def menu_commands(input)
	end

	def play(saved=false)
		reset if not saved
		begin
			update_display
			puts @display.to_s
			input = @board.use

			get_str(input) if @board.interactive == "string"

			case input
			when 'Q' then exit
			when 'B' then break
			when 'S' then save
			when "\r" then select_space
			when " " then select_space
			end

		end until @board.empty_spaces == 0 || @winner != nil
		tally_wins
		post_game
		play if read_char == 'y'
	end

	def name_player(name)
		display = name_display("#{name} what is your new name")
		puts display.to_s
		str_row = display.child_loc(display.children[0][0])[2] + 2
		get_string do |partial|
			display.insert_string([str_row,0], value: " ", background: :green)
			display.insert_string([str_row,0], value: partial, background: :green)
			puts display.to_s
		end
	end

	def name_display(prompt)
		display = Formatter.new(1, prompt.length)
		display.insert_string([0,0], value: prompt, background: :green)
		screen = Formatter.new(window_height, window_width, :green)
		screen.add_child(:center, display)
		screen
	end

	def tally_wins
		if @winner == nil
			@player1.draw += 1
			@player2.draw += 1
		elsif @winner == @player1.setter
			@player1.wins += 1
			@player2.loss += 1
		elsif @winner == @player2.setter
			@player1.loss += 1
			@player2.wins += 1
		end
	end

	def post_game
	end

	def first_empty_space(pos)
		pos = [@board.rows-1, pos[1]]
		while @board.get_space(pos) and not @board.get_space(pos).empty?# || pos[0] < 0
			pos = [pos[0]-1, pos[1]]
		end
		@board.get_space(pos) ? @board.get_space(pos) : nil
	end

	def reset
		@board.reset
		@display = @board.full(:light_magenta)
		@winner = nil
	end

	def update_display
		@display.child_loc(@board.format)
	end

	def change_turn
		@turn = @turn.object_id === @player1.object_id ? @player2 : @player1
	end

	def select_space
		@board.current_space
	end

	def save
		File.open("#{File.expand_path File.dirname(__FILE__)}/../data/#{self.class.to_s}.yml", 'w') {|f| YAML::dump([] << self, f)}
		exit
	end
end