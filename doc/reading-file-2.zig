// Reading the file in one shot

const std = @import("std");

pub fn main() !void {
    var da = std.heap.DebugAllocator(.{}){};
    const allocator = da.allocator();

    const data = try std.fs.cwd().readFileAlloc(allocator, "input.txt", 4096);
    defer allocator.free(data);

    var iter = std.mem.splitScalar(u8, data, '\n');

    while (iter.next()) |line| {
        std.debug.print("Line:\n {s}\n", .{line});
    }
}

// This is so much better
