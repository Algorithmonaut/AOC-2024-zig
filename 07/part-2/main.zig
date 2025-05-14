const std = @import("std");
const print = std.debug.print;

const Equation = struct {
    test_value: isize,
    values: []isize,
    operation_sequences: [][]bool,

    fn is_operation_sequence_valid(self: *Equation, index: usize) bool {
        const sequence = self.operation_sequences[index];

        var sum: isize = self.values[0];

        for (0..self.values.len - 1) |i| {
            switch (sequence[i]) {
                true => sum *= self.values[i + 1],
                false => sum += self.values[i + 1],
            }
        }

        if (sum == self.test_value) return true;
        return false;
    }

    fn is_any_operation_sequence_valid(self: *Equation) bool {
        var valid = false;

        for (0..self.operation_sequences.len) |i|
            valid = valid or is_operation_sequence_valid(self, i);

        return valid;
    }
};

// NOTE: This function is beautiful
pub fn generate_combinations2(
    allocator: std.mem.Allocator,
    len: usize,
) ![][]bool {
    // Holds the total number of combinations, 2^len (same as 1 << len)
    const num_combinations = @as(usize, 1) << @truncate(len);
    var result = try allocator.alloc([]bool, num_combinations);

    for (0..num_combinations) |i| {
        var combination = try allocator.alloc(bool, len);

        for (0..len) |j| {
            const bit_pos = len - 1 - j;
            // 00...001, and shift 1 to bit pos
            const mask = @as(usize, 1) << @intCast(bit_pos);
            combination[j] = (i & mask) != 0;
        }
        result[i] = combination;
    }

    return result;
}

pub fn generate_combinations(
    allocator: std.mem.Allocator,
    len: usize,
) ![][]u8 {
    const num_combinations = 3 ** len;

    // Each divisor isolates a digit in the base 3 representation
    // E.g. for len 3: [9, 3, 1]
    var divisors = try allocator.alloc(usize, len);

    {
        var pow: usize = 1;
        for (0..(len - 1)) |_| {
            pow *= 3;
        }

        for (0..len) |j| {
            divisors[j] = pow;
            pow /= 3;
        }
    }

    var result = try allocator.alloc([]u8, num_combinations);

    for (0..num_combinations) |i| {
        var combination = try allocator.alloc(u8, len);

        for (0..len) |j| {
            const divisor = divisors[j];
            const digit: u8 = @intCast((i / divisor) % 3);
            combination[j] = digit;
        }

        result[i] = combination;
    }
}

pub fn get_equations_from_input(allocator: std.mem.Allocator) ![]*Equation {
    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var reader = buf_reader.reader();

    var equations_list = std.ArrayList(*Equation).init(allocator);

    while (true) {
        const line = (try reader.readUntilDelimiterOrEofAlloc(
            allocator,
            '\n',
            1024 * 1024,
        )) orelse break;

        var line_it = std.mem.splitAny(u8, line, ": ");
        var line_equation = try allocator.create(Equation);

        line_equation.test_value = try std.fmt.parseInt(isize, line_it.next().?, 10);
        _ = line_it.next().?;

        var values_list = std.ArrayList(isize).init(allocator);
        while (line_it.next()) |value| try values_list.append(try std.fmt.parseInt(isize, value, 10));
        line_equation.values = values_list.items;

        line_equation.operation_sequences = try generate_combinations(
            allocator,
            line_equation.values.len - 1,
        );

        try equations_list.append(line_equation);
    }

    return equations_list.items;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa_allocator = gpa.allocator();
    var arena = std.heap.ArenaAllocator.init(gpa_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const len = 3;

    _ = try generate_combinations(allocator, len);

    const equations_list = try get_equations_from_input(allocator);

    var sum: isize = 0;
    for (equations_list) |equation| {
        if (equation.is_any_operation_sequence_valid()) sum += equation.test_value;
    }

    print("Counter: {}\n", .{sum});
}
