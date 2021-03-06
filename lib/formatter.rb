require "colorize"
require "io/console"
require_relative "coordinate"

=begin
		The formatter class is used to create complex colored designs within the
		format rectangle. Each space can be individually colored and set with a value
		then returned as its string representation. This is to avoid issues which arise
		when centering colored strings.
=end

module FormatHelper

	def full_screen(format, background=nil)
		format_height = format.rows > window_height-2 ? format.rows + 4 : window_height
		format_width = format.columns > window_width - 2 ? format.columns + 4 : window_width
		screen_fill = Formatter.new(format_height, format_width, background)
		screen_fill.add_child(:center, format)
		screen_fill
	end

	def window_width
		IO.console.winsize[1]
	end

	def window_height
		IO.console.winsize[0]
	end

end

class Formatter
	include FormatHelper
	attr_reader :rows, :columns, :format, :map, :children
	attr_accessor :parent

	def initialize(rows, columns, default_background=nil)
		@rows = rows
		@columns = columns
		@default_background = default_background
		@format = Array.new(@rows) {Array.new(@columns) {" "}}
		@map = Array.new(@rows) {Array.new(@columns) {{value: " ", color: nil, background: default_background}}}
		
		@parent = nil
		@children = []
	end

	def add_child(pos, child)
		raise(ArgumentError, "Child must be of class Formatter") if child.class != Formatter
		raise(ArgumentError, "Child must be smaller than the parent") if self < child
		pos = center.to_coord - (child.size.to_coord/2) if pos == :center
		pos = [0, 0] if pos == :first
		pos = pos.class == Coordinate ? pos : pos.to_coord
		child.parent = self
		@children << [child, pos]
		map_format(pos, child)
		self
	end

	def set_background(background)
		@default_background = background
		each {|space, pos| set_space(pos, background: background)}
	end

	def get_space(pos)
		pos = pos.class == Coordinate ? pos.to_a : pos
		return nil if pos[1] > @columns-1 || pos[0] > @rows-1 
		@map[pos[0]][pos[1]]
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
		string = hash[:value] ? hash[:value] : nil
		char_index = 0
		while get_space(pos)
			hash[:value] = string[char_index] if hash[:value]
			set_space(pos, hash) if hash[:value]
			pos += direction
			char_index += 1
			char_index = 0 if char_index >= string.length && hash[:value] && string.class == Symbol
		end
	end

	def to_s
		formatted_str = ''
		@rows.times {|row| @columns.times do |column|
			@format[row][column] = @map[row][column][:value]
			@format[row][column] = @format[row][column].colorize(color: @map[row][column][:color]) if @map[row][column][:color]
			@format[row][column] = @format[row][column].colorize(background: @map[row][column][:background]) if @map[row][column][:background]
			@format[row][column] = @format[row][column].uncolorize if @map[row][column][:color] == nil and @map[row][column][:background] == nil
		end}
		@format.each {|line| formatted_str += line.join + "\n"}
		formatted_str
	end

	def [](index)
		@map[index]
	end

	def each
		@rows.times {|i| @columns.times {|j| yield(@map[i][j], [i, j])}}
	end

	def size
		[@rows, @columns]
	end

	def center
		[@rows/2, @columns/2]
	end

	def <(format)
		raise(ArgumentError, "Argument must be of class Formatter") if format.class != self.class
		size[0] < format.size[0] && size[1] < format.size[1]
	end

	def child_loc(child)
		@children.each do |child_arr|
			return [*child_arr[1].to_a, *(child_arr[1] + child.size).to_a] if child_arr[0] == child
		end
		nil
	end

	def insert_string(pos, format_hash, center=true)
		format_hash[:value].lines.each do |line|
			line = line.gsub("\n",'')
			color = format_hash[:color] ? format_hash[:color] : nil
			background = format_hash[:background] ? format_hash[:background] : nil
			if not center
				set_direction(pos, [0,1], value: line, color: color, background: background)
			else
				set_direction(pos.to_coord + [0,((@columns - line.length)/2)], [0,1], value: line, color: color, background: background)
			end
			pos[0] += 1
		end
	end

	def valid_pos?(pos)
		get_space(pos) != nil
	end

	def map_format(pos, format)
		format.each do |space, space_pos|
			mapped_pos = pos + space_pos
			@map[mapped_pos.row][mapped_pos.column] = space if valid_pos?(mapped_pos)
		end
	end

	def update
		@children.each do |child|
			pos = child[1]
			child[0].each do |space, space_pos|
				mapped_pos = pos + space_pos
				@map[mapped_pos.row][mapped_pos.column] = space if valid_pos?(mapped_pos)
			end
		end
		@parent.update if @parent != nil
	end
end

#include FormatHelper
#f1 = Formatter.new(10, 20, :black)
#f1[0]
#f2 = full_screen(f1, :white)
#pos = f2.child_loc(f1)
#p pos
#f2.insert_string([pos[2]+1,0], {value: "Hello\nJared Archey\nWhat is your name", color: :red, background: :green})
#puts f2.to_s
#f1.set_direction([0,0],[1,1], background: :green)
#puts f2.to_s
#f2 = Formatter.new(25, 25, :red)
#f3 = Formatter.new(10, 10, :blue)
#f2.add_child(:center, f3)
#f3.set_direction([0,0], [1,1], background: :yellow)
#puts f2.to_s
#f2.set_direction([0,0],[0,1], value:"Aha", color: :black, background: :white)
#f2.set_direction([0,0],[1,1], value:"Bab", color: :white, background: :green)
#f1.add_child(:center, f2)
#f1.set_direction([0,0],[1,1], background: :green)
#f3.set_direction([0,0], [1,1], background: :black)
#f4 = full_screen(f1, :black)
#f3.set_direction([0,0],[1,0], background: :white)
#puts f4.to_s
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