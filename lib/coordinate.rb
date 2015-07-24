class Array
	def to_coord
		raise(ArgumentError, "Array must be length 2") if self.length != 2
		Coordinate.new(*self)
	end
end

class Coordinate
	attr_accessor :row, :column

	def initialize(row, column)
		@row = row
		@column = column
	end

	def to_a
		[@row, @column]
	end

	def +(coordinate)
		if coordinate.class == self.class
			Coordinate.new(@row + coordinate.row, @column + coordinate.column)
		elsif coordinate.class == Array
			raise(ArgumentError, "Array must be of length 2") if coordinate.length != 2
			Coordinate.new(@row + coordinate[0], @column + coordinate[1])
		elsif coordinate.class == Fixnum
			Coordinate.new(@row + coordinate, @column + coordinate)
		else
			raise(ArgumentError, "Coordinate must be of class coordinate, array, or fixnum")
		end
	end

	def -(coordinate)
		if coordinate.class == self.class
			Coordinate.new(@row - coordinate.row, @column - coordinate.column)
		elsif coordinate.class == Array
			raise(ArgumentError, "Array must be of length 2") if coordinate.length != 2
			Coordinate.new(@row - coordinate[0], @column - coordinate[1])
		elsif coordinate.class == Fixnum
			Coordinate.new(@row - coordinate, @column - coordinate)
		else
			raise(ArgumentError, "Coordinate must be of class coordinate, array, or fixnum")
		end
	end

	def /(coordinate)
		if coordinate.class == self.class
			Coordinate.new(@row / coordinate.row, @column / coordinate.column)
		elsif coordinate.class == Array
			raise(ArgumentError, "Array must be of length 2") if coordinate.length != 2
			Coordinate.new(@row / coordinate[0], @column / coordinate[1])
		elsif coordinate.class == Fixnum
			Coordinate.new(@row / coordinate, @column / coordinate)
		else
			raise(ArgumentError, "Coordinate must be of class coordinate, array, or fixnum")
		end
	end
end