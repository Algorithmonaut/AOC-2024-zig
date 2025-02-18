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

fn has_adjacent_char(
    allocator: std.mem.Allocator,
    grid: [][]u8,
    pos: [2]isize,
    char: u8,
) !std.ArrayList([2]isize) {
    var positions = std.ArrayList([2]isize).init(allocator);

    for ([_]isize{ -1, 0, 1 }) |ri| {
        for ([_]isize{ -1, 0, 1 }) |rj| {
            if (ri == 0 and rj == 0) continue;

            const i = pos[0] + ri;
            const j = pos[1] + rj;

            if (i < 0 or i >= grid.len) continue;
            if (j < 0 or j >= grid[0].len) continue;

            if (grid[@intCast(i)][@intCast(j)] == char) {
                std.debug.print("Found {c} next to index {any}\n", .{
                    char,
                    pos,
                });

                try positions.append([_]isize{ i, j });
            }
        }
    }

    return positions;
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
            if (grid[@intCast(i)][@intCast(j)] == 'X') {
                var poss_m = try has_adjacent_char(allocator, grid, [_]isize{ i, j }, 'M');

                for (poss_m.items) |pos_m| {
                    var poss_a = try has_adjacent_char(allocator, grid, pos_m, 'A');

                    for (poss_a.items) |pos_a| {
                        var poss_s = try has_adjacent_char(allocator, grid, pos_a, 'S');

                        sum += poss_s.items.len;

                        poss_s.clearAndFree();
                    }

                    poss_a.clearAndFree();
                }

                std.debug.print("\n{any}\n", .{poss_m.items});
                poss_m.clearAndFree();
            }
        }
    }

    std.debug.print("\n\n{}", .{sum});
}
