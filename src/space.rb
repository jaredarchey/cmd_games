require_relative "../lib/formatter"

class Space
	attr_reader :value, :pos, :format

	def initialize(pos, value=" ", format={})
		@pos = pos
		@value = value
		@format = Formatter.new(1,3, format[:background])
		@format.set_space([0,1], value: @value, color: format[:color])
	end

	def set(format)
		@format.set_background(format[:background]) if format[:background]
		@format.set_space([0,1], format)
		@value = format[:value] if format[:value]
	end

	def to_s
		@format.to_s
	end
end

#s = Space.new([0,0], "X", background: :black, color: :red)
#puts s.to_s