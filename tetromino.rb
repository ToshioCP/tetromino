module Tetromino
    # Tetrominos' definition

    # When placing a tetromino on a coordinate grid,
    # the leftmost square of the tetromino is positioned at the origin (0, 0).
    # If there are multiple squares on the leftmost side,
    # the square that is highest within that column is placed at the origin.
    # For example, if a T-shaped tetromino is rotated 90 degrees clockwise,
    # the square that originally formed the bottom of the T (now rotated) is placed at the origin.

    # Original shapes of tetromino.
    # A tetromino is considered the same tetromino even if it is rotated by 90 degrees,
    # reflected along a vertical axis, or transformed by repeating these operations.

    T_Line = [[0,0], [1,0], [2,0], [3,0]]
    T_L = [[0,0], [0,-1], [1,-1], [2,-1]]
    T_T = [[0,0], [1,0], [2,0], [1,1]]
    T_Square = [[0,0], [1,0], [0,-1], [1,-1]]
    T_Z = [[0,0], [1,0], [1,-1], [2,-1]]

    Tetrominoes = [T_Line, T_L, T_T, T_Square, T_Z]

    # Tetromino object is one of the 5 shapes above.
    # However, a shape obtained by rotation by 90 degrees or reflection along a vertical line is also the same tetromino.
    # Therefore, the object contains all the variations.
    # It is a set of such shapes.

    class Tetromino
        def initialize(shape)
            unless shape.class == Array && Tetrominoes.include?(shape)
                raise "Illegal argument"
            end
            t1 = rotate_tetromino(shape)
            t2 = rotate_tetromino(t1)
            t3 = rotate_tetromino(t2)
            @t = [shape, t1, t2, t3]
            @t = @t.inject([]){|a, b| a + [b, reflect_tetromino(b)]}.map{|s| s.sort}.uniq
        end
        def each
            @t.each do |s|
                yield(s)
            end
        end

        private
        def rotate(a)
            [-a[1], a[0]]
        end
        def find_lu(shape)
            shape = shape.sort do |s1, s2|
                if s1[0] == s2[0]
                    r = (s1[1] <=> s2[1])
                    r ? -r : nil
                else
                    s1[0]<=>s2[0]
                end
            end
            shape[0]
        end
        def rotate_tetromino(shape)
            shape = shape.map{|s| rotate(s)}
            move=find_lu(shape)
            shape.map{|s| [s[0]-move[0], s[1]-move[1]]}
        end
        def reflect_tetromino(shape)
            shape = shape.map{|s| [-s[0], s[1]]}
            move=find_lu(shape)
            shape.map{|s| [s[0]-move[0], s[1]-move[1]]}
        end
    end

    class Board
        attr_reader :width, :height
        attr_accessor :s, :p, :n
        # Example: 3x3 rectangle
        # (0, 3) => top left
        # (3, 3) => top right
        # (0, 0) => bottom left
        # (3, 0) => bottom left
        def initialize (width, height)
            raise "Illegal argument" unless width.class == Integer && height.class == Integer
            raise "Illegal argument" unless width>0 && height>0
            raise "Illegal argument" unless width*height % 4 == 0
            
            @width, @height = width, height
            @s = Array.new(@width*@height, 0)
            @p = 0 # The next index of @order
            @n = 0 # The number for the previous tetromino to embed
            @max = @width*@height/4 # The maximum tetromino number to embed the board
            # Converter between coordinate (x, y) and index s for @s.
            @xy2s = ->(x){@width*x[1] + x[0]}
            @s2xy = ->(s){y, x = s.divmod(@width); [x, y]}
            # reflection across a vertical line
            @ref_across_v = ->(x){[@width-1-x[0], x[1]]}
            # reflection across a horizontal line
            @ref_across_h = ->(x){[x[0], @height-1-x[1]]}
            # reflection about the center of the rectangle
            # It is the same as rotation about the center.
            @rot_180 = ->(x){[@width-1-x[0], @height-1-x[1]]}
            # 90-degree rotation about the center of the square
            @rot_90 = ->(x){@width == @height ? [@height-1-x[1], x[0]] : nil}
            # -90-degree rotation about the center of the square
            @rot_270 = ->(x){@width == @height ? [x[1], @width-1-x[0]] : nil}

            @order = []
            (0...@width).each do |i|
                (0...@height).to_a.reverse.each do |j|
                    @order << [i, j]
                end
            end
        end

        def get(x, y)
            return nil unless (0...@width).include?(x) && (0...@height).include?(y)
            @s[@xy2s.call([x, y])]
        end
        def put(x, y, v)
            return nil unless (0...@width).include?(x) && (0...@height).include?(y)
            @s[@xy2s.call([x, y])] = v
        end
    
        # This method is a deep copy.
        def dup
            b = Board.new(@width, @height)
            b.p = @p
            b.n = @n
            b.s = @s.dup
            b
        end

        # The following methods, which is rot_90, rot_270, rot_180, ref_across_v and ref_across_h, create a new board.
        # Be careful that @p and @n are not correct in those boards.

        def trans(p)
            board = Board.new(@width, @height)
            (0...@s.size).each do |i|
                x, y = @s2xy.call(i)
                x0, y0 = p.call([x, y])
                board.put(x, y, get(x0, y0))
            end
            board
        end
        private(:trans)
        def rot_90
            return nil unless @width == @height
            trans(@rot_270)
        end
        def rot_180
            trans(@rot_180)
        end
        def rot_270
            return nil unless @width == @height
            trans(@rot_90)
        end
        def ref_across_v
            trans(@ref_across_v)
        end
        def ref_across_h
            trans(@ref_across_h)
        end

        def ==(other)
            relatives.each do |s|
                return true if s.same_pattern?(other)
            end
            false
        end

        # Try to embed a tetromino, the argument t is an element of a tetromino object
        def try(t)
            i, j = @order[@p];
            t.each do |k, l|
                return false unless (0...@width).include?(i+k) && (0...@height).include?(j+l)
                return false unless get(i+k, j+l) == 0
            end
            @n += 1
            t.each do |k, l|
                put(i+k, j+l, @n)
            end
            if @n < @max
                update_p
            end
            @n
        end
        def back
            return if @n == 0
            (0...@width).each do |i|
                (0...@height).each do |j|
                    put(i, j, 0) if get(i, j) == @n
                end
            end
            @p = 0
            update_p
            @n -= 1
        end

        def to_s
            # Print the square. Be careful for the vertical direction
            # @s[3][0] => top left
            # @s[3][3] => top right
            # @s[0][0] => bottom left
            # @s[3][3] => bottom left
            s = ""
            (0...@height).to_a.reverse.each do |j|
                (0...@width).each do |i|
                    s += "#{get(i, j)} "
                end
                s += "\n"
            end
            s
        end

        def same_pattern?(other)
            return false unless other.class == Board
            return false unless other.width == @width && other.height == @height
            relation = {}
            (0...@width).each do |i|
                (0...@height).each do |j|
                    if relation.key?(get(i, j))
                        return false unless other.get(i, j) == relation[get(i, j)]
                    else
                        relation[get(i, j)] = other.get(i, j)
                    end
                end
            end
            true
        end
    
        private

        def update_p
            while @p < @order.size
                i, j = @order[@p]
                break if get(i, j) == 0
                @p += 1
            end
        end
        def relatives
            s0 = self
            s1 = rot_90
            s2 = rot_180
            s3 = rot_270
            s4 = ref_across_v
            s5 = ref_across_h
            s6 = rot_90 ? rot_90.ref_across_v : nil
            s7 = rot_90 ? rot_90.ref_across_h : nil
            [s0, s1, s2, s3, s4, s5, s6, s7].compact
        end
    end
end