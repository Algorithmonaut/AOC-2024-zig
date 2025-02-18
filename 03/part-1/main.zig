const std = @import("std");
const parser = @import("parser.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var reader = buf_reader.reader();

    var line_buf = std.ArrayList(u8).init(allocator);
    defer line_buf.deinit();

    var sum: isize = 0;

    while (true) {
        reader.readUntilDelimiterArrayList(
            &line_buf,
            '\n',
            1024 * 1024,
        ) catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };

        sum += try process_line(line_buf.items);

        line_buf.clearRetainingCapacity();
    }

    std.debug.print("{}", .{sum});
}

fn is_valid_operation_input(operation_input: []const u8) bool {
    var has_comma: bool = false;

    for (operation_input, 0..) |c, j| {
        if (c == ',') has_comma = true;
        if ((c < '0' or c > '9') and c != ',') return false;
        if (c == ',' and (j == 0 or j == operation_input.len - 1)) return false;
    }
    if (operation_input.len == 0) return false;
    if (!has_comma) return false;

    return true;
}

fn parse_operation_input(operation_input: []const u8) !isize {
    var lparser = parser.Parser.init(operation_input);

    while (lparser.peek() != ',') {
        lparser.advance();
    }

    const num1 = try std.fmt.parseInt(isize, lparser.input[lparser.start..lparser.pos], 10);
    lparser.advance();
    const num2 = try std.fmt.parseInt(isize, operation_input[lparser.pos..operation_input.len], 10);

    return (num1 * num2);
}

fn process_line(line: []u8) !isize {
    var sum: isize = 0;

    var line_parser = parser.Parser.init(line);

    var i: usize = 0;
    blk: while (i < line_parser.input.len - 3) : (i += 1) {
        if (std.mem.eql(u8, line_parser.input[i .. i + 3 + 1], "mul(")) {
            line_parser.set_pos(i + 3 + 1);
            line_parser.set_start();

            while (!line_parser.is_at_end() and line_parser.peek() != ')') {
                line_parser.advance();
            }

            const operation_input = line_parser.input[line_parser.start..line_parser.pos];

            if (!is_valid_operation_input(operation_input)) continue :blk;
            sum += try parse_operation_input(operation_input);
        }
    }

    return sum;
}
