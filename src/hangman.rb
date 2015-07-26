require_relative "game"

class Hangman < Game

	def initialize
		gallows
		@length = [2, 5]
		super(1,1,"string")
		@guess_history = []
		@incorrect = 0
		random_word
		@main_menu << ["Play Game", \
					   "Create Word", \
					   "Adjust min length | current: #{@length[0]}", \
					   "Adjust max length | current: #{@length[1]}"]
		resize
	end

	def hang
		case @incorrect
		when 0 then gallows
		when 1 then @gallow.set_space([1,2], value: 'o', color: :black)
		when 2 then @gallow.set_space([2,2], value: '|', color: :black)
		when 3 then @gallow.set_space([2,1], value: '/', color: :black)
		when 4 then @gallow.set_space([2,3], value: '\\', color: :black)
		when 5 then @gallow.set_space([3,2], value: '*', color: :black)
		when 6 then @gallow.set_space([3,1], value: '/', color: :black)
		when 7  
			@gallow.set_space([3,3], value: '\\', color: :black)
			@winner = 'dead'
		end
	end

	def gallows
		@gallow = Formatter.new(6, 13, :light_magenta)
		@gallow.set_direction([5,0], [0,1], value: :-, color: :black)
		@gallow.set_space([5,6], value: '+', color: :black)
		4.times {|i| @gallow.set_space([4-i, 6], value: '|', color: :black)}
		@gallow.set_direction([0,2],[0,1], value: '+---+', color: :black)
	end

	def update_display
		board_loc = super
		gallow_loc = @board.format.columns > @gallow.columns ? (@gallow.columns-@board.columns)/2 : 0
		@display.add_child([board_loc[0]-7, board_loc[1]+gallow_loc], @gallow)
		@display.insert_string([board_loc[2]+1,0], value: @guess_history.border_join("|"), color: :black) if @guess_history.length > 0
	end

	def menu_selection
		case @main_menu.current_option
		when 0 then play
		when 1 then create_word
		end
	end

	def menu_commands(input)	
		case input
		when "\e[C" then adjust_option(:right)
		when "\e[D" then adjust_option(:left)
		end 
	end

	def adjust_option(direction)
		adjust_min_length(direction) if @main_menu.current_option == 2
		adjust_max_length(direction) if @main_menu.current_option == 3
	end

	def adjust_min_length(direction)
		@length[0] += 1 if direction == :right
		@length[0] -= 1 if direction == :left
		@length[0] = @length[1]-1 if @length[0] >= @length[1]
		@length[0] = 2 if @length[0] < 2
		@main_menu.change_option_label(2, "Adjust min length | current: #{@length[0]}")
	end

	def adjust_max_length(direction)
		@length[1] += 1 if direction == :right
		@length[1] -= 1 if direction == :left
		@length[1] = @length[0] + 1 if @length[1] <= @length[0]
		@length[1] = 10 if @length[1] > 10
		@main_menu.change_option_label(3, "Adjust max length | current: #{@length[1]}")
	end

	def create_word
		str = user_string("Enter a word between #{@length[0]} and #{@length[1]} characters")
		create_word if !str.length.between?(*@length)
		@word = str
		resize
	end

	def random_word
		word_list = []
		File.open("#{File.expand_path File.dirname(__FILE__)}/../data/dictionary.txt", 'r').each {|line| word_list << line.chomp }
		word = nil
		while word == nil
			index = rand(0...word_list.length)
			word = word_list[index] if word_list[index].length.between?(*@length)
		end
		@word = word.downcase
		resize
	end

	def get_str(char)
		@guess_history << char
		indeces = @word.indeces_of(char)
		@incorrect += 1 if indeces.length == 0
		indeces.each do |index|
			@board.set_space([0,index], value: char)
		end
		hang
	end

	def resize
		@board.resize(1, @word.length)
		@display = @board.full(:light_magenta)
		update_display
	end

	def post_game
		display = full_screen(@gallow, :cyan)
		string = @winner == 'dead' ? "You couldnt guess the word | #{@word}" : \
		                             "Congratulations, you guessed the word | #{@word}"
		display.insert_string([display.child_loc(@gallow)[2]+1,0], value: string, color: :black)
		display.insert_string([display.child_loc(@gallow)[2]+3,0], value: "Play Again? y/n", color: :black)
		
		puts display.to_s
		random_word
		@guess_history = []
		@incorrect = 0 
		hang
	end

	def reset
		super
	end
end

#Hangman.new.begin