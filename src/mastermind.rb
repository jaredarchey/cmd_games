require_relative "game"

class MasterMind < Game
	attr_reader :length, :attempts, :guess, :correct, :history, :code, :repeats

	def initialize
		@length = 4
		@attempts = 12

		@guess = ''
		@correct = 0
		@history = []
		@repeats = true
		@code = random_code(@repeats)

		super(@attempts, @length, "string")
		@main_menu << ["Play Game",  \
			           "Create Code", \
		               "Adjust Length | current: #{@length}",\
		               "Adjust Attempts | current: #{@attempts}", \
		           	   "Allow Repeats | true"]
	end

	def update_display #This is costing ALOT of speed, I only need to update when play is called
		@options_fill = {r: :red, o: :light_red, y: :yellow, g: :green, b: :cyan, i: :blue, v: :magenta}
		options = Board.new(1,7,"string")
		index = 0
		options.each_space do |space|
			space.set(value: @options_fill.keys[index].to_s, color: @options_fill[@options_fill.keys[index]])
			index += 1
		end
		f = Formatter.new(@display.children[0][0].rows+14, @display.columns, :white)
		f.add_child(:center, @board.format)
		board_loc = f.child_loc(@board.format)
		option_pos = [board_loc[2], (@display.columns-options.format.columns)/2]
		f.add_child(option_pos, options.format)
		@display = f
		f.set_direction([board_loc[2]+4,0], [0,1], value: :" ", background: :white)
		f.insert_string([board_loc[2]+4,0], value: "Guess the secret code", background: :yellow, color: :red)
		f.set_direction([board_loc[2]+5,0], [0,1], value: :" ", background: :white)
		f.insert_string([board_loc[2]+5,0], value: "Last guess had #{@correct} correct", background: :yellow, color: :red)
		f.set_direction([board_loc[2]+6,0], [0,1], value: :" ", background: :white)
		f.insert_string([board_loc[2]+6,0], value: @guess, background: :red, color: :white)
	end

	def menu_selection
		case @main_menu.current_option
		when 0 then play
		when 1 then @code = create_code
		end
	end

	def menu_commands(input)	
		case input
		when "\e[C" then adjust_option(:right)
		when "\e[D" then adjust_option(:left)
		end 
	end

	def adjust_option(direction)
		adjust_length(direction)   if @main_menu.current_option == 2
		adjust_attempts(direction) if @main_menu.current_option == 3
		adjust_repeats if @main_menu.current_option == 4
	end

	def post_game
		display = full_screen(Formatter.new(1,1,:white), :white)
		summary = Formatter.new(@history.length + 4, display.columns, :white)
		string = @correct == @length ? "Congratulations, you guessed the code #{@code}" : \
		                               "HAHAHAHA, you couldnt guess the code #{@code}"
		summary.insert_string([0,0], value: string, background: :green)
		summary.insert_string([1,0], value: "Guess History", background: :green)
		@history.each_index do |i|
			summary.insert_string([i+3,0], value: "Guess #{i+1}: #{@history[i]}", color: :black)
		end
		display.add_child(:center, summary)
		display.insert_string([display.child_loc(summary)[2]+2, 0], value: "Play Again? y/n", color: :black)
		puts display.to_s
		@history = []
		@correct = 0
		@code = random_code
	end

	def adjust_length(direction)
		@length += 1 if direction == :right
		@length -= 1 if direction == :left
		@length = 6 if @length > 6
		@length = 2 if @length < 2
		@code = random_code
		resize
		@main_menu.change_option_label(2, "Adjust Length | current: #{@length}")
	end

	def adjust_attempts(direction)
		@attempts += 1 if direction == :right
		@attempts -= 1 if direction == :left
		@attempts = 4 if @attempts < 4
		@attempts = 15 if @attempts > 15
		resize
		@main_menu.change_option_label(3, "Adjust Attempts | current: #{@attempts}")
	end

	def adjust_repeats
		@repeats = !@repeats
		@main_menu.change_option_label(4, "Allow Repeats | #{@repeats.to_s}")
		@code = random_code(@repeats)
	end

	def get_str(char) #This is where the game is played
		@guess += char if 'roygbiv'.include?(char)
		if @guess.length == @length
			@correct = 0
			empty_space = first_empty_space([0,0])
			pos = nil
			@board.each_space {|space, space_pos| pos = space_pos if space == empty_space}
			@board.columns.times do |column|
				@board.get_space([pos[0],column]).set(value: @guess[column], color: @options_fill[@guess[column].to_sym], background: @options_fill[@guess[column].to_sym])#@options_fill[@guess[column]])
			end
			@guess.chars.each_index do |i|
				@correct += 1 if @code[i] == @guess[i]
			end
			@winner = true if @correct == @length
			@history << @guess
			@guess = ''
		end
	end

	def create_code(test=nil)
		str = test == nil ? user_string("Enter a #{@length} digit code") : test
		create_code(test) if (str.chars.select {|char| 'roygbiv'.include?(char)}).length != @length
		@code = str
	end

	def resize
		@board.resize(@attempts, @length)
	end

	def random_code(repeats=true)
		colors = 'roygbiv'
		code = ''
		while code.length != @length
			index = rand(0...colors.length)
			code += colors[index] if !repeats && !code.include?(colors[index]) || repeats
		end
		code
	end

	def reset
		super
	end
end

#MasterMind.new.begin