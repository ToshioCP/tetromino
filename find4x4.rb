require_relative "tetromino.rb"

class Array
    # uniq method using == instead of Object#eql? 
    def uniq_ee
        u = []
        each do |e|
            u << e unless u.include?(e) # include? uses ==.
        end
        u
    end
end

def solve(tetrominoes)
    return if tetrominoes.empty?
    n = tetrominoes.size
    (0...n).each do |i|
        tetromino = tetrominoes[i]
        ts = tetrominoes.dup
        ts.delete_at(i)
        tetromino.each do |t|
            if @board.try(t) # success
                if @board.n == 4 #complete
                    @solution << @board.dup
                else
                    solve(ts)
                end
                @board.back
            end
        end
    end
end

@solution = []
@board = Tetromino::Board.new(4, 4)
t0 = Tetromino::Tetromino.new(Tetromino::T_Line)
t1 = Tetromino::Tetromino.new(Tetromino::T_L)
t2 = Tetromino::Tetromino.new(Tetromino::T_T)
t3 = Tetromino::Tetromino.new(Tetromino::T_Square)
t4 = Tetromino::Tetromino.new(Tetromino::T_Z)
solve([t0, t1, t1, t2, t2, t3, t4])

@solution = @solution.uniq_ee

print "\n\n"

def concat(s, t)
    s = s.split("\n")
    t = t.split("\n")
    c = (0..3).map{|i| s[i] + "    " + t[i] + "\n"}
    c[0] + c[1] + c[2] + c[3]
end 
    
s = @solution.map{|sol| sol.to_s}
t = concat(s[0], s[1])
t = concat(t, s[2])
t = concat(t, s[3])
t = concat(t, s[4])
print t, "\n"
t = concat(s[5], s[6])
t = concat(t, s[7])
t = concat(t, s[8])
t = concat(t, s[9])
print t, "\n"
print "There are #{@solution.size} patterns.\n\n"
