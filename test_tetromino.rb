require 'minitest/autorun'
require_relative 'Tetromino.rb'

class TestTetromino < Minitest::Test
    include Tetromino

    def test_each
        tetromino = Tetromino.new(T_L)
        ts = [
            [[0,0], [0,-1], [1,-1], [2,-1]],
            [[0,0], [1,0], [1,1], [1,2]],
            [[0,0], [1,0], [2,0], [2,-1]],
            [[0,0], [1,0], [0,-1], [0,-2]],
            [[0,0], [1,0], [2,0], [2,1]],
            [[0,0], [1,0], [1,-1], [1,-2]],
            [[0,0], [1,0], [2,0], [0,-1]],
            [[0,0], [0,-1], [0,-2], [1,-2]]
        ]
        ts = ts.map{|t| t.sort}
        tetromino.each do |t|
            assert ts.include?(t.sort)
        end
    end
end

class TestBoard < Minitest::Test
    include Tetromino
    def setup
    end
    def teardown
    end

    def test_rot_90
        s = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]
        square0 = Board.new(4,4)
        (0..15).each do |i|
            x, y = i.divmod(4)
            square0.put(x, y, s[i])
        end
        square1 = square0.rot_90
        assert_equal [4,8,12,16,3,7,11,15,2,6,10,14,1,5,9,13], (0..15).map{|i| x, y = i.divmod(4); square1.get(x, y)}
    end
    def test_get_put
        board = Board.new(4,2)
        (0..7).each do |i|
            y, x = i.divmod(4)
            board.put(x, y, i)
            assert_equal i, board.get(x, y)
        end
    end
    def test_dup
        b = Board.new(3,4)
        d = b.dup
        assert_equal b.p, d.p
        assert_equal b.n, d.n
        assert_equal b.s, d.s
        b.put(1,1,1)
        refute_equal b.s, d.s
    end
    def test_equivalent
        b = Board.new(3,4)
        d = Board.new(3,4)
        [[1,1,1,2], [2,3,1,2], [0,2,3,1], [1,3,3,1]].each do |x|
            b.put(x[0],x[1],x[2])
            d.put(x[0],x[1],x[3])
        end
        assert(b == d)
    end
    def test_try
        b = Board.new(4,4)
        n = b.try([[0,0], [1,0], [2,0], [0,-1]])
        assert_equal 1, n
        assert_equal [1,1,1,1], [b.get(0,3), b.get(1,3), b.get(2,3), b.get(0,2)]
        n = b.try([[0,0], [0,-1], [0,-2], [1,-2]])
        refute n
    end
    def test_back
        b = Board.new(4,4)
        n = b.try([[0,0], [1,0], [2,0], [0,-1]])
        n = b.try([[0,0], [0,-1], [1,-1], [2,-1]])
        assert_equal 2, n
        assert_equal [1,1,1,1,2,2,2,2], [b.get(0,3), b.get(1,3), b.get(2,3), b.get(0,2), b.get(0,1), b.get(0,0), b.get(1,0), b.get(2,0)]
        b.back
        assert_equal [0,0,0,0], [b.get(0,1), b.get(0,0), b.get(1,0), b.get(2,0)]
        assert_equal 1, b.n
    end
    def test_to_s
        board = Board.new(4,2)
        (0..7).each do |i|
            y, x = i.divmod(4)
            board.put(x, y, i)
        end
        assert_equal "4 5 6 7 \n0 1 2 3 \n", board.to_s
    end
end