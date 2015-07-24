require_relative "spec_helper"

describe Board  do
	
	before :each do
		@b = Board.new(5, 3)
	end

	it "should initialize with rows and columns" do
		expect([@b.rows, @b.columns]).to eq([5, 3])
	end

	it "should initialize with a grid of spaces" do 
		count = 0
		@b.board.each { |row| row.each do |space|
			expect(space.class).to eq(Space)
			count += 1
		end}
		expect(count).to eq(15)
	end

	it "should initialize with formatting" do 
		expect(@b.format.rows).to eq(@b.rows*2+1)
		expect(@b.format.columns).to eq(@b.columns*3 + @b.columns+1)
	end

	it "should optionally highlight the current space" do 
		b = Board.new(3, 3, true)
		b.board[0][0].format.each {|space| expect(space[:background]).to eq(:white)}
	end

	describe "#each_space" do 
		it "should yield each space and pos" do 
			@b.each_space { |space, pos| expect(@b.board[pos[0]][pos[1]]).to eq(space) }
		end
	end

	describe "#each_format" do #Shorthand for @b.format.each
		it "should yield each format space and pos" do 
			board_format, actual_format = [], []
			@b.each_format do |format, pos|
				board_format << format
				actual_format << @b.format[pos[0]][pos[1]]
			end
			expect(board_format.length).to eq(actual_format.length)
			board_format.length.times {|i| expect(board_format[i]).to eq(actual_format[i])}
		end
	end

	describe "#resize" do
		it "should resize and update" do 
			@b.resize(10, 10)
			count = 0
			@b.each_space {count += 1}
			expect(count).to eq(100)
			expect(@b.format.rows).to eq(@b.rows*2+1)
			expect(@b.format.columns).to eq(@b.columns*3 + @b.columns+1)
		end
	end

	describe "#set_color" do 
		it "should be able to change its color" do 
			@b.set_color(color: :red, background: :white)
			expect([@b.background, @b.border_color]).to eq([:white, :red])
			@b.each_format {|format| expect(format[:background]).to eq(@b.background)}
		end
	end

	describe "#move_highlight" do 
		it "should only highlight a single space" do 
			b = Board.new(3, 3, true)

			b.move_highlight(:right)
			board_highlight_helper(b, [0,1])

			b.move_highlight(:down)
			board_highlight_helper(b, [1,1])

			b.move_highlight(:left)
			board_highlight_helper(b, [1,0])

			b.move_highlight(:up)
			board_highlight_helper(b, [0,0])
		end

		it "should re-map the position if its off the board" do 
			b = Board.new(3, 3, true)

			b.move_highlight(:left)
			board_highlight_helper(b, [0,2])

			b.move_highlight(:up)
			board_highlight_helper(b, [2,2])

			b.move_highlight(:right)
			board_highlight_helper(b, [2,0])

			b.move_highlight(:down)
			board_highlight_helper(b, [0,0])
		end
	end

	describe "#to_s" do 
		it "should return itself as a string" do 
			expect(@b.to_s.class).to eq(String)
			expect(@b.to_s.lines.length).to eq(@b.rows*2+1)
		end
	end

	describe "#set_space" do
		it "should set a value in the space" do 
			@b.set_space([0,0], "X")
			expect(@b.board[0][0].format[0][1]).to eq(value: "X", color: nil, background: @b.background)
		end

		it "should also set a space with a hash" do 
			@b.set_space([0,0], value: "X", color: :white, background: :blue)
			expect(@b.board[0][0].format[0][1]).to eq({value: "X", color: :white, background: :blue})
			@b.board[0][0].format.each {|format| expect(format[:background]).to eq(:blue)}
		end
	end

	describe "#get_space" do
		it "should return a space" do 
			expect(@b.get_space([0,0])).to eq(@b.board[0][0])
		end
	end

	describe "#set_by_pattern" do 
		it "should set horizontal spaces" do 
			@b.set_by_pattern([0,0],[0,1], value: "X", color: :white, background: :blue)
			@b.board[0].each {|space| expect(space.format[0][1]).to eq({value: "X", color: :white, background: :blue})}
		end

		it "should set vertical spaces" do 
			@b.set_by_pattern([0,0],[1,0], value: "X", color: :white, background: :blue)
			@b.rows.times do |i|
				expect(@b.board[i][0].format[0][1]).to eq({value: "X", color: :white, background: :blue})
			end
		end

		it "should set diagonal spaces" do 
			@b.set_by_pattern([0,0],[1,1], value: "X", color: :white, background: :blue)
			[@b.rows, @b.columns].min.times do |i|
				expect(@b.board[i][i].format[0][1]).to eq({value: "X", color: :white, background: :blue})
			end
		end
	end

	describe "#get_by_pattern" do 
		it "should get all horizontal spaces" do 
			spaces = @b.get_by_pattern([0,0],[0,1])
			@b.columns.times {|i| expect(@b.board[0][i]).to eq(spaces[i])}
		end

		it "should get all vertical spaces" do 
			spaces = @b.get_by_pattern([0,0],[1,0])
			@b.rows.times {|i| expect(@b.board[i][0]).to eq(spaces[i])}
		end

		it "should get all diagonal spaces" do 
			spaces = @b.get_by_pattern([0,0],[1,1])
			[@b.rows, @b.columns].min.times {|i| expect(@b.board[i][i]).to eq(spaces[i])}
		end
	end

	describe "#in_a_row" do 
		it "should find if there are multiple values horizontally" do 
			3.times { |i| @b.set_space([0,i], value: "X") }
			expect(@b.in_a_row(3)).to eq("X")
			expect(@b.in_a_row(4)).to eq(nil)
		end

		it "should find if there are multiple values vertically" do 
			3.times { |i| @b.set_space([i,0], value: "X") }
			expect(@b.in_a_row(3)).to eq("X")
			expect(@b.in_a_row(4)).to eq(nil)
		end

		it "should find if there are multiple values vertically" do 
			3.times { |i| @b.set_space([i,i], value: "X") }
			expect(@b.in_a_row(3)).to eq("X")
			expect(@b.in_a_row(4)).to eq(nil)
		end
	end
end

def board_highlight_helper(board, pos)
	board.each_space do |space, space_pos|
		space_pos == pos ? space.format.each {|format| expect(format[:background]).to eq(:white)} : \
				           space.format.each {|format| expect(format[:background]).to eq(:black)}
	end
end