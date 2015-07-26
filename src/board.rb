require_relative "space"
require_relative "../lib/input_helper"
require_relative "../lib/formatter"
require_relative "../lib/command"  
require_relative "../lib/coordinate"

class Array
	def border_join(str)
		str + self.join(str) + str
	end
end

class String
	def indeces_of(char)
		(0...self.length).find_all { |i| self[i] == char }
	end
end

class Board
	include FormatHelper
	include InputHelper
	attr_reader :board, :format, :rows, :columns, :background, :border_color, :interactive

	def initialize(rows, columns, interactive="string")
		@interactive = interactive
		@background, @border_color = :black, :blue
		@rows, @columns = rows, columns
		@current_space = @interactive != "string" ? Coordinate.new(0,0) : nil
		new_board
	end

	def use(test=nil)
		input = test == nil ? read_char : test
		case input
		when "\e[A" then move_highlight(:up) if @interactive == "2D" || @interactive == "1D_C"
		when "\e[B" then move_highlight(:down) if @interactive == "2D" || @interactive == "1D_C"
		when "\e[C" then move_highlight(:right) if @interactive == "2D" || @interactive == "1D_R"
		when "\e[D" then move_highlight(:left) if @interactive == "2D" || @interactive == "1D_R"
		when "\u0003" then exit 
		else return input
		end
		nil
	end

	def set_space(pos, format)
		@board[pos[0]][pos[1]].set(value: format) if format.class == String
		@board[pos[0]][pos[1]].set(format) if format.class == Hash
	end

	def get_space(pos)
		pos = pos.to_a
		return nil if !pos[0].between?(0,@rows-1) || !pos[1].between?(0, @columns-1)
		@board[pos[0]][pos[1]]
	end

	def set_by_pattern(pos, direction, format)
		while get_space(pos)
			set_space(pos, format)
			pos = (pos.to_coord + direction.to_coord).to_a
		end
	end

	def get_by_pattern(pos, direction)
		spaces = []
		while get_space(pos) != nil
			spaces << get_space(pos)
			pos = (pos.to_coord + direction.to_coord).to_a
		end
		spaces
	end

	def in_a_row(num)
		each_space do |space, pos|
			horiz, vert, diag1, diag2 = [], [], [], []
			num.times {|i| horiz << get_space(pos.to_coord + [0,i]).value if get_space(pos.to_coord + [0,i]) && get_space(pos.to_coord + [0,i]).value != " "}
			num.times {|i| vert  << get_space(pos.to_coord + [i,0]).value if get_space(pos.to_coord + [i,0]) && get_space(pos.to_coord + [i,0]).value != " "}
			num.times {|i| diag1 << get_space(pos.to_coord + [i,i]).value if get_space(pos.to_coord + [i,i]) && get_space(pos.to_coord + [i,i]).value != " "}
			num.times {|i| diag2 << get_space(pos.to_coord + [-i,i]).value if get_space(pos.to_coord + [-i,i]) && get_space(pos.to_coord + [-i,i]).value != " "}
			return horiz.uniq[0] if horiz.length == num && horiz.uniq.length == 1
			return vert.uniq[0]  if vert.length == num && vert.uniq.length == 1
			return diag1.uniq[0] if diag1.length == num && diag1.uniq.length == 1
			return diag2.uniq[0] if diag2.length == num && diag2.uniq.length == 1
		end
		nil
	end

	def empty_spaces
		count = 0
		each_space { |space| count += 1 if space.empty? }
		count
	end

	def resize(rows, columns)
		@rows, @columns = rows, columns
		new_board
	end

	def reset
		new_board
	end

	def set_color(hash)
		@background = hash[:background] if hash[:background]
		@border_color = hash[:color] if hash[:color]
		new_board
	end

	def current_space(pos=nil)
		return nil if @current_space == nil
		pos ? @current_space.to_a : get_space(@current_space.to_a)
	end

	def to_s
		@format.to_s
	end

	def each_space
		@rows.times {|i| @columns.times {|j| yield(@board[i][j], [i,j])}}
	end

	def each_format
		@format.each do |space, pos|
			yield(space, pos)
		end
	end

	def full(color=nil)
		full_screen(@format, color)
	end

	def move_highlight(direction)
		case direction
		when :down then @current_space += [1,0]
		when :up then @current_space += [-1,0]
		when :left then @current_space += [0,-1]
		when :right then @current_space += [0,1]
		end
		@current_space.row = @rows-1 if @current_space.row < 0
		@current_space.row = 0 if @current_space.row > @rows-1
		@current_space.column = @columns-1 if @current_space.column < 0
		@current_space.column = 0 if @current_space.column > @columns-1
		highlight_current_space
	end

	private

	def new_board
		@board = Array.new(@rows) {|i| Array.new(@columns) {|j| Space.new(" ", background: @background)}}
		@format = Formatter.new(@rows*2+1, @columns*3+@columns+1, @background)
		border
		@board.length.times {|i| @board[i].length.times {|j| @format.add_child(space_start([i,j]), @board[i][j].format)}}
		highlight_current_space
	end

	def border
		separator = Array.new(@columns) {"---"}.border_join("+")
		walls = separator.indeces_of("+")
		@format.rows.times do |i|
			if i.even?
				@format.set_direction([i,0],[0,1], value: separator, color: @border_color)
			else
				walls.each {|j| @format.set_space([i,j], value: "|", color: @border_color)}
			end
		end
	end

	def space_start(pos)
		row, column = [], []
		(1...@format.rows).step(2) {|i| row << i}
		(1...@format.columns).step(4) {|i| column << i}
		[row[pos[0]], column[pos[1]]]
	end

	def highlight_current_space
		return nil if @current_space == nil
		each_space do |space, pos|
			pos == @current_space.to_a ? space.set(background: space.alt_color) : space.set(background: @background)
		end
		@current_space
	end
end

#b = Board.new(3, 3, true)
#b.set_space([0,0], value: "X")
#b.set_space([1,0], value: "X")
#b.set_space([2,0], value: "X")
#p b.in_a_row(3)
#puts b.to_s
#c = b.full
#p b.use
#b.move_highlight(:down)
#b.move_highlight(:right)
#b.move_highlight(:up)
#b.move_highlight(:left)
#puts c.to_s
#c = b.full
#b.set_space([0,0], value: "X", color: :blue, background: :white)
#puts c.to_s
#b.set_space([0,0], value: "X", color: :blue, background: :white)
#puts b.to_s
#b.each_space do |space, pos|
#	p space, pos
#end