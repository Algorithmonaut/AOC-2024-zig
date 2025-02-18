// NOTE: A empty line at end of input file is required. Fuck it I'm not that
// good at parsing.

const std = @import("std");
const parsers = @import("parser.zig");

const input_array = @embedFile("input.txt");

pub fn main() !void {
    var sum: usize = 0;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var file_parser = parsers.Parser.init(input_array);

    while (!file_parser.is_at_end()) : (file_parser.advance()) {
        if (file_parser.peek() != '\n') continue;

        var line_parser = parsers.Parser.init(
            file_parser.input[file_parser.start..file_parser.pos],
        );

        if (try check_line(allocator, &line_parser)) sum += 1;
        file_parser.advance();
        file_parser.set_start();
    }

    std.debug.print("{}", .{sum});
}

/////////////

// Miam repetition
fn check_monotonic(list: *std.ArrayList(isize)) bool {
    const Status = enum { inc, dec };

    const first_status: Status = blk: {
        if (list.items[0] < list.items[1]) {
            break :blk Status.inc;
        } else break :blk Status.dec;
    };

    var i: usize = 0;

    while (i < list.items.len - 1) : (i += 1) {
        var new_status: Status = undefined;
        if (list.items[i] < list.items[i + 1]) {
            new_status = .inc;
        } else new_status = .dec;

        if (first_status != new_status) return false;
    }

    return true;
}

fn check_increase(list: *std.ArrayList(isize)) bool {
    var i: usize = 0;

    while (i < list.items.len - 1) : (i += 1) {
        const remoteness: u64 = @abs(list.items[i] - list.items[i + 1]);
        if (!(remoteness >= 1 and remoteness <= 3)) return false;
    }

    return true;
}

fn check_line(allocator: std.mem.Allocator, parser: *parsers.Parser) !bool {
    var list = std.ArrayList(isize).init(allocator);
    defer list.deinit();

    var it = std.mem.splitScalar(u8, parser.input, ' ');

    while (it.next()) |token| {
        const num = try std.fmt.parseInt(isize, token, 10);
        try list.append(num);
    }

    return check_monotonic(&list) and check_increase(&list);
}
