const std = @import("std");

pub fn fileToArray(allocator: std.mem.Allocator, filepath: []const u8) ![][]u8 {
    // Open the file
    const file = try std.fs.cwd().openFile(filepath, .{});
    defer file.close();

    // Read the entire file content
    const content = try file.readToEndAlloc(allocator, 1024 * 1024); // 1MB limit
    defer allocator.free(content);

    // Count number of lines and line width
    var line_count: usize = 0;
    var line_width: usize = 0;
    var first_line = true;

    for (content) |char| {
        if (char == '\n') {
            line_count += 1;
            first_line = false;
        } else if (first_line) {
            line_width += 1;
        }
    }

    // Create 2D array
    var array = try allocator.alloc([]u8, line_count);
    for (array) |*row| {
        row.* = try allocator.alloc(u8, line_width);
    }

    // Fill the array
    var current_line: usize = 0;
    var current_col: usize = 0;

    for (content) |char| {
        if (char == '\n') {
            current_line += 1;
            current_col = 0;
        } else {
            array[current_line][current_col] = char;
            current_col += 1;
        }
    }

    return array;
}

// Example usage
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const array = try fileToArray(allocator, "input.txt");
    defer {
        for (array) |row| {
            allocator.free(row);
        }
        allocator.free(array);
    }

    // Now you can use the 2D array
    for (array) |row| {
        std.debug.print("{s}\n", .{row});
    }
}
