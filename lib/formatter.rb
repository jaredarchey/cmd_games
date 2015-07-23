require "colorize"
require "io/console"
require_relative "coordinate"

=begin
		The formatter class is used to create complex colored designs within the
		format rectangle. Each space can be individually colored and set with a value
		then returned as its string representation. This is to avoid issues which arise
		when centering colored strings.
=end

class Formatter
	attr_reader :rows, :columns, :format, :map

	def initialize(rows, columns, default_background=nil)
		@rows = rows
		@columns = columns
		@default_background = default_background

		@format = Array.new(@rows) {Array.new(@columns) {" "}}
		@map = Array.new(@rows) {Array.new(@columns) {{value: " ", color: nil, background: default_background}}}
	end

	def set_background(background)
		@default_background = background
		each {|space, pos| set_space(pos, background: background)}
	end

	def get_space(pos, map=false)
		pos = pos.class == Coordinate ? pos.to_a : pos
		return nil if pos[1] > @columns-1 || pos[0] > @rows-1 
		map ? @map[pos[0]][pos[1]] : @format[pos[0]][pos[1]]
	end

	def get_direction(pos, direction)

	end

	def set_space(pos, hash)
		raise(ArgumentError, "Value must be a single character") if hash[:value] and hash[:value].length != 1
		pos = pos.class == Coordinate ? pos.to_a : pos
		@map[pos[0]][pos[1]][:value] = hash[:value] if hash[:value]
		@map[pos[0]][pos[1]][:color] = hash[:color] if hash[:color]
		@map[pos[0]][pos[1]][:background] = hash[:background] if hash[:background]
		if hash[:uncolor]
			@map[pos[0]][pos[1]][:color] = nil
			@map[pos[0]][pos[1]][:background] = nil
		end
		update
	end

	def set_direction(pos, direction, hash)
		direction = direction.class == Coordinate ? direction : direction.to_coord
		pos = pos.class == Coordinate ? pos : pos.to_coord
		char_index = 0
		while get_space(pos)
			set_space(pos, hash)
			pos += direction
			char_index += 1
			char_index = 0 if char_index >= hash[:value].length if hash[:value]
		end
	end

	def to_s
		formatted_str = ''
		@format.each {|line| formatted_str += line.join + "\n"}
		formatted_str
	end

	def [](index)
		@format[index]
	end

	def []=(index, array)
		raise(IndexError, "Index out of range") if @format[index] == nil || array.length != @columns
		@format[index] = array
	end

	def each #I want this to yield the map space
		@rows.times {|i| @columns.times {|j| yield(@map[i][j], [i, j])}}
	end

	private

	def update
		@rows.times {|row| @columns.times do |column|
			@format[row][column] = @map[row][column][:value]
			@format[row][column] = @format[row][column].colorize(color: @map[row][column][:color]) if @map[row][column][:color]
			@format[row][column] = @format[row][column].colorize(background: @map[row][column][:background]) if @map[row][column][:background]
			@format[row][column] = @format[row][column].uncolorize if @map[row][column][:color] == nil and @map[row][column][:background] == nil
		end}
	end
end

#f = Formatter.new(3, 3, :black)
#f.set_space([0,0], value: "X")
#puts f.to_s
#p f.map[0][0]
#f.set_direction([0,0], [1,0], background: :red)
#puts f.to_s
#f.set_background(:black)
#f.set_space([0,0], value: "X")
#f.to_s
#p f.format
#f[5] = [1, 2, 3]
#p f.format