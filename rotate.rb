require "matrix"
class Sigma
	@@value = 0.1
	@@k = 1
	@@p = 5
	@@stop = false
	def self.next
		if @@k + 1 < @@p
			@@k += 1
			@@value /= 10
		else
			@@stop = true
		end
	end

	def self.stop?
		@@stop
	end

	def self.ij(a)
		if @@stop then return [-1, -1] end
		n = a.size
		for i in (0...n)
			for j in (i + 1...n)
				if a[i][j].abs > @@value
					return [i, j]
				end
			end
		end
		self.next
		self.ij a
	end
end

class Array
	def to_m
		Matrix[*self]
	end

	def copy
		Array.new(self.size){|i| self[i].clone}
	end
end

def sign x
	if x == 0 then return 0 end
	x / x.abs
end

a = [
	[2, 1, 1],
	[1, 2.5, 1],
	[1, 1, 3]
]
a.map!{|v| v.map! &:to_f}
n = a.size
w = Matrix.I n


while not Sigma.stop?
	i, j = Sigma.ij a
	# p [i, j]
	if i + j < 0 then 
		break 
	end
	m = a.copy
	d = Math.sqrt((m[i][i] - m[j][j]) ** 2 + 4 * m[i][j] ** 2)
	c = Math.sqrt((1 + (m[i][i] - m[j][j]).abs / d) / 2)
	s = sign((m[i][i] - m[j][j]) * m[i][j]) * Math.sqrt(1 - c ** 2)
	# p [c, s]
	t = Matrix.I(n).to_a
	t[i][i], t[j][j], t[i][j], t[j][i] = c, c, -s, s 
	for k in (0...n)
		if k != i and k != j
			a[k][i] = c * m[k][i] + s * m[k][j]
			a[i][k] = a[k][i]
			a[k][j] = -s * m[k][i] + c * m[k][j]
			a[j][k] = a[k][j]
		end
	end
	a[i][i] = m[i][i]*c**2 + 2*c*s*m[i][j] + m[j][j]*s**2
	a[j][j] = m[i][i]*s**2 - 2*c*s*m[i][j] + m[j][j]*c**2
	a[i][j] = 0
	a[j][i] = 0
	w *= t.to_m
end
p Array.new(n){|i| a[i][i]}
puts ""
w.t.to_a.each do |i|
	p i
end