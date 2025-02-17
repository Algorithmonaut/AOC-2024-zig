const std = @import("std");
const parsers = @import("../../utils/parser.zig");

const input_array = @embedFile("input.txt");
const number_of_lines = blk: {
    var count: usize = 0;

    @setEvalBranchQuota(100000);
    for (input_array) |c| {
        if (c == '\n') count += 1;
    }

    break :blk count;
};

pub fn main() !void {
    var parser = parsers.Parser.init(input_array);
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

    for (left_numbers, right_numbers) |left_number, right_number| {
        std.debug.print("{}:{}\n", .{ left_number, right_number });

        const value: i32 = left_number - right_number;
        sum += blk: {
            if (value < 0) {
                break :blk -value;
            } else break :blk value;
        };
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
