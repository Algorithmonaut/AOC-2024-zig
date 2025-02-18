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

fn is_pattern_increment_sum(
    grid: [][]u8,
    pos: [2]isize,
) void {
    if (grid[@intCast(pos[0])][@intCast(pos[1])] != 'A') return;

    const directions: [2][2]isize = .{ .{ 1, 1 }, .{ -1, 1 } };
    const pos_v: @Vector(2, isize) = pos;

    if (pos_v[0] <= 0 or pos_v[0] > grid.len - 2) return;
    if (pos_v[1] <= 0 or pos_v[1] > grid[0].len - 2) return;

    for (directions) |direction| {
        const direction_v: @Vector(2, isize) = direction;

        const direction_inverse_v = blk: {
            const increment_1: @Vector(2, isize) = @splat(1);
            break :blk (~direction_v) + increment_1;
        };

        var new_pos_v = pos_v + direction_v;
        const character1: u8 = grid[@intCast(new_pos_v[0])][@intCast(new_pos_v[1])];

        new_pos_v = pos_v + direction_inverse_v;
        const character2: u8 = grid[@intCast(new_pos_v[0])][@intCast(new_pos_v[1])];

        if (!((character1 == 'M' and character2 == 'S') or (character1 == 'S' and character2 == 'M')))
            return;
    }

    sum += 1;
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
            is_pattern_increment_sum(grid, .{ i, j });
        }
    }

    std.debug.print("Sum: {}", .{sum});
}
