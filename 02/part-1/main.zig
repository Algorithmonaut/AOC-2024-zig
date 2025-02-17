const std = @import("std");
const parsers = @import("parser.zig");

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
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var allocator = arena.allocator();

    var file_parser = parsers.Parser.init(input_array);

    while (!file_parser.is_at_end()) : (file_parser.advance()) {
        if (file_parser.peek() != '\n') continue;

        const line_parser = parsers.Parser.init(
            file_parser.input[file_parser.start..file_parser.pos],
        );

        file_parser.advance();
        file_parser.set_start();

        try parse_line(&allocator, line_parser);
    }
}

fn parse_line(allocator: *std.mem.Allocator, parser: parsers.Parser) !void {
    const len = parser.input.len;
    const slice_ptr = try allocator.alloc(u8, len);

    for (parser.input, 0..) |c, i| {
        slice_ptr[i] = c;
    }

    for (slice_ptr) |c| {
        std.debug.print("{c}", .{c});
    }
    std.debug.print("\n", .{});
}
