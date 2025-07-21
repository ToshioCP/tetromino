import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle

# ---- GLobal functions ----
# The variable name 'shape' means a tetromino shape. It is NOT a tetromino.
# A tetromino is a set of shapes that are congruent but has different orientation.

def rotate(x, y):
    return (-y, x)

def reflect(x, y):
    return (-x, y)

def normalize(shape):
    """
    The leftmost point comes first.
    If two or more points have the same smallest x-coordinate,
    the bottommost among them comes first.
    Then, all the points are translated so that the first point moves to the origin (0, 0).
    """
    shape = sorted(shape, key=lambda p: (p[0], p[1]))
    ox, oy = shape[0]
    return [(x - ox, y - oy) for x, y in shape]

# ---- Tetromino Base Shapes ----

SHAPES = {
    "I": ((0, 0), (1, 0), (2, 0), (3, 0)),
    "L": ((0, 0), (0, -1), (1, -1), (2, -1)),
    "T": ((0, 0), (1, 0), (2, 0), (1, 1)),
    "O": ((0, 0), (1, 0), (0, -1), (1, -1)),
    "Z": ((0, 0), (1, 0), (1, -1), (2, -1))
}

# ---- Classes ----

# Tetromino is a list of congruent shapes.
class Tetromino:
    def __init__(self, name):
        self.name = name
        self.variations = self._generate_variations(SHAPES[name])

    def _generate_variations(self, shape):
        shapes = []
        for _ in range(4):
            s = shape
            for _ in range(2):
                norm = normalize(s)
                if norm not in shapes:
                    shapes.append(norm)
                s = [reflect(x, y) for x, y in s]
            shape = [rotate(x, y) for x, y in shape]
        return shapes

class Board:
    def __init__(self, width, height):
        self.width = width
        self.height = height
        self.size = width * height
        self.grid = [0] * self.size
        self.p = 0 # the index of the first cell with value zero. This cell will be the next one to try placing a tetromino.
        self.n = 0 # The tetrominoes placed on the board are numbered starting from one. This indicates the number of the last tetromino placed.
        self.max = self.size // 4 # Maximum number of tetrominoes.

    # index to coordinate
    def i2c(self, p):
        if p < 0 or p >= self.size:
            return None
        return divmod(p, self.height)

    # coordinate to index
    def c2i(self, x, y):
        if x < 0 or x >= self.width:
            return None
        if y < 0 or y >= self.height:
            return None
        return x * self.height + y

    def get(self, x, y):
        p = self.c2i(x, y)
        if p is not None:
            return self.grid[p]
        else:
            return None

    def put(self, x, y, value):
        p = self.c2i(x, y)
        if p is not None:
            self.grid[p] = value

    def rotate90(self):
        if self.width != self.height:
            return None
        grid = [0] * self.size
        for i in range(len(self.grid)):
            x, y =rotate(*self.i2c(i))
            x += self.width - 1
            j = self.c2i(x, y)
            grid[j] = self.grid[i]
        new_board = self.copy()
        new_board.grid = grid[:]
        return new_board

    def rotate180(self):
        grid = [0] * self.size
        for i in range(len(self.grid)):
            x, y =self.i2c(i)
            x = -x + self.width - 1
            y = -y + self.height - 1
            j = self.c2i(x, y)
            grid[j] = self.grid[i]
        new_board = self.copy()
        new_board.grid = grid[:]
        return new_board

    def reflect(self):
        grid = [0] * self.size
        for i in range(len(self.grid)):
            x, y = reflect(*self.i2c(i))
            x += self.width - 1
            j = self.c2i(x, y)
            grid[j] = self.grid[i]
        new_board = self.copy()
        new_board.grid = grid[:]
        return new_board

    def try_place(self, shape):
        if self.p >= self.size:
            return False
        x0, y0 = self.i2c(self.p)
        for dx, dy in shape:
            x, y = x0 + dx, y0 + dy
            if not (0 <= x < self.width and 0 <= y < self.height):
                return False
            if self.get(x, y) != 0:
                return False
        self.n += 1
        for dx, dy in shape:
            self.put(x0 + dx, y0 + dy, self.n)
        if self.n < self.max:
            self._update_p()
        return True

    def backtrack(self):
        if self.n == 0:
            return
        for y in range(self.height):
            for x in range(self.width):
                if self.get(x, y) == self.n:
                    self.put(x, y, 0)
        self.p = 0
        self._update_p()
        self.n -= 1

    def _update_p(self):
        while self.p < self.size:
            c = self.i2c(self.p)
            if c is None:
                break
            x, y = c
            if self.get(x, y) == 0:
                break
            self.p += 1

    def copy(self):
        new_board = Board(self.width, self.height)
        new_board.grid = self.grid[:]
        new_board.p = self.p
        new_board.n = self.n
        return new_board

    # Two board are the same when The corresponding tetrominoes occupy the same positions on both boards.
    # Note that the number of the corresponding tetrominoes can be different.
    def _same_pattern(self, other):
        if not self.samewh(other):
            return False
        relation = {}
        for a, b in zip(self.grid, other.grid):
            if a not in relation:
                relation[a] = b
            elif relation[a] != b:
                return False
        return True

    # Two boards are considered to have the same pattern if one can be transformed into the other by a rotation or reflection.
    def same_pattern(self, other):
        if not self.samewh(other):
            return False
        b = other
        if self.width == self.height: # square shaped board
            for _ in range(4):
                rb = b
                for _ in range(2):
                    if self._same_pattern(rb):
                        return True
                    rb = rb.reflect()
                b = b.rotate90()
            return False
        else:
            for _ in range(2):
                rb = b
                for _ in range(2):
                    if self._same_pattern(rb):
                        return True
                    rb = rb.reflect()
                b = b.rotate180()
            return False

    def samewh(self, other):
        return self.width == other.width and self.height == other.height


# piece_pool: list of pieces (tetrominoes). In this puzzle, Six L-shaped tetrominoes are used.
#             So, the pool is [L, L, L, L, L, L]
# used: list of names that used in a solution
# depth: number of tetrominoes embeded in the board
# n: The number of distinct tetrominoes used in the solution. Some puzzles require this number to be greater than or equal to a certain value.
class Solver:
    def __init__(self, width, height, piece_pool):
        self.piece_pool = piece_pool
        self.board = Board(width, height)
        self.solutions = []

    def solve(self, used, depth, n):
        if depth == self.board.max:
            if len(set(p.name for p in used)) >= n:
                self.solutions.append(self.board.copy())
            return
        for i, piece in enumerate(self.piece_pool):
            if piece is None:
                continue
            self.piece_pool[i] = None
            for variant in piece.variations:
                if self.board.try_place(variant):
                    self.solve(used + [piece], depth + 1, n) # recursive call
                    self.board.backtrack()
            self.piece_pool[i] = piece

    def unique_solutions(self):
        if len(self.solutions) == 0:
            return None
        unique = []
        for sol in self.solutions:
            if all(not sol.same_pattern(u) for u in unique):
                unique.append(sol)
        return unique

# ---- 表示関数 ----

COLORS = ["#FFD700", "#ADFF2F", "#FF69B4", "#87CEFA", "#D2691E", "#90EE90", "#FFA07A", "#9370DB"]

def draw_board(board, ax):
    for y in range(board.height):
        for x in range(board.width):
            val = board.get(x, board.height - 1 - y)
            if val > 0:
                color = COLORS[(val - 1) % len(COLORS)]
                rect = Rectangle((x, y), 1, 1, facecolor=color, edgecolor='black')
                ax.add_patch(rect)
    ax.set_xlim(0, board.width)
    ax.set_ylim(0, board.height)
    ax.set_aspect('equal')
    ax.axis('off')

def show_solutions(solutions, filename):
    if not solutions:
        print("No solutions to show.")
        return
    cols = 5
    rows = (len(solutions) + cols - 1) // cols
    fig, axes = plt.subplots(rows, cols, figsize=(cols*2, rows*2))
    axes = axes.flatten()
    for i, sol in enumerate(solutions):
        draw_board(sol, axes[i])
    for i in range(len(solutions), len(axes)):
        axes[i].axis('off')
    plt.tight_layout()
    plt.savefig(filename)
    plt.show()

# main program
def main():
    tetromino_shapes = ["L"] * 6
    piece_pool = [Tetromino(x) for x in tetromino_shapes]
    # The area of the rectangle is 4*6 = 24.
    # Therefore, the width and height is one of: (12, 2), (8, 3) or (6, 4)
    for wh in ((12, 2), (8, 3), (6, 4)):
        solver = Solver(wh[0], wh[1], piece_pool)
        solver.solve([], 0, 1)
        solutions = solver.unique_solutions()
        show_solutions(solutions, f"tetromino_solutions_{wh[0]}x{wh[1]}.png")

if __name__ == "__main__":
    main()
