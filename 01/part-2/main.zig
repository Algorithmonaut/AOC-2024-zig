const std = @import("std");

const input_array = @embedFile("input.txt");
const number_of_lines = blk: {
    var count: usize = 0;

    @setEvalBranchQuota(100000);
    for (input_array) |c| {
        if (c == '\n') count += 1;
    }

    break :blk count;
};

const Parser = struct {
    pos: usize = 0,
    start: usize = 0,
    input: []const u8,

    fn init(input: []const u8) Parser {
        return .{ .input = input };
    }

    fn peek(self: *Parser) u8 {
        if (self.pos >= self.input.len - 1) unreachable;
        return self.input[self.pos];
    }

    fn advance(self: *Parser) void {
        self.pos += 1;
    }

    fn set_start(self: *Parser) void {
        self.start = self.pos;
    }

    fn is_at_end(self: *Parser) bool {
        return self.pos >= self.input.len - 1;
    }
    fn is_at_number(self: *Parser) bool {
        const c = self.input[self.pos];
        return c >= '0' and c <= '9';
    }
};

pub fn main() !void {
    var parser = Parser.init(input_array);
    var right: bool = false;

    var left_numbers: [number_of_lines]i32 = undefined;
    var right_numbers: [number_of_lines]i32 = undefined;

    var i: usize = 0;

    while (!parser.is_at_end()) {
        while (!parser.is_at_number()) parser.advance();
        parser.set_start();
        while (parser.is_at_number()) parser.advance();
        std.debug.print("Number: {s}\n", .{parser.input[parser.start..parser.pos]});

        const number = try std.fmt.parseInt(i32, parser.input[parser.start..parser.pos], 10);
        std.debug.print("Number: {}\n", .{number});
        switch (right) {
            false => left_numbers[i] = number,
            true => {
                right_numbers[i] = number;
                i += 1;
            },
        }

        right = !right;
    }

    bubble_sort(&left_numbers);
    bubble_sort(&right_numbers);

    var sum: isize = 0;

    for (left_numbers) |left_number| {
        var counter: isize = 0;
        for (right_numbers) |right_number| {
            counter += if (left_number == right_number) 1 else 0;
        }

        sum += left_number * counter;
    }

    std.debug.print("{}\n", .{sum});
}

fn bubble_sort(array: []i32) void {
    var swapped: bool = undefined;

    while (true) {
        swapped = false;

        var i: usize = 0;
        while (i < array.len - 1) : (i += 1) {
            if (array[i] > array[i + 1]) {
                const temp = array[i];
                array[i] = array[i + 1];
                array[i + 1] = temp;

                swapped = true;
            }
        }

        if (swapped == false) {
            break;
        }
    }
}
