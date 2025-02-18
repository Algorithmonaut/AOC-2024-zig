const std = @import("std");

var sum: usize = 0;

// NOTE: Maybe dedimtionalizing the array would be more optimized,
// and there is surely a better way to parse the file.
fn file_to_array(allocator: std.mem.Allocator, filepath: []const u8) ![][]u8 {
    const file = try std.fs.cwd().openFile(filepath, .{});
    defer file.close();

    // NOTE: Limit filesize to 1MB
    const content = try file.readToEndAlloc(allocator, 1024 * 1024);
    defer allocator.free(content);

    var line_count: usize = 0;
    var line_width: usize = 0;
    var first_line = true;

    for (content) |c| {
        if (c == '\n') {
            line_count += 1;
            first_line = false;
        } else if (first_line) {
            line_width += 1;
        }
    }

    var grid = try allocator.alloc([]u8, line_count);
    for (grid) |*row| {
        row.* = try allocator.alloc(u8, line_width);
    }

    var current_line: usize = 0;
    var current_col: usize = 0;

    for (content) |c| {
        if (c == '\n') {
            current_line += 1;
            current_col = 0;
        } else {
            grid[current_line][current_col] = c;
            current_col += 1;
        }
    }

    return grid;
}

fn get_occurence_count(
    grid: [][]u8,
    pos: [2]isize,
) void {
    const directions = blk: {
        var temp: [8][2]i8 = undefined;
        var index: usize = 0;

        inline for ([_]i8{ -1, 0, 1 }) |dx| {
            inline for ([_]i8{ -1, 0, 1 }) |dy| {
                if (dx == 0 and dy == 0) continue;
                temp[index] = .{ dx, dy };
                index += 1;
            }
        }

        break :blk temp;
    };

    outer: for (directions) |direction| {
        var pos_v: @Vector(2, isize) = pos;
        const direction_v: @Vector(2, isize) = direction;

        const letters: [4]u8 = .{ 'X', 'M', 'A', 'S' };

        var i: usize = 0;
        while (i <= 3) : (i += 1) {
            if (pos_v[0] < 0 or pos_v[0] > grid.len - 1) continue :outer;
            if (pos_v[1] < 0 or pos_v[1] > grid[0].len - 1) continue :outer;
            if (grid[@intCast(pos_v[0])][@intCast(pos_v[1])] != letters[i]) continue :outer;
            pos_v += direction_v;
        }

        sum += 1;
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const grid = try file_to_array(allocator, "input.txt");
    defer {
        for (grid) |row| allocator.free(row);
        allocator.free(grid);
    }

    var i: isize = 0;
    while (i < grid.len) : (i += 1) {
        var j: isize = 0;
        while (j < grid[0].len) : (j += 1) {
            get_occurence_count(grid, .{ i, j });
        }
    }

    std.debug.print("Sum: {}", .{sum});
}
