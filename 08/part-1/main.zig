const std = @import("std");

const print = std.debug.print;

pub fn main() !void {
    var da = std.heap.DebugAllocator(.{}){};
    const allocator = da.allocator();

    const data = try std.fs.cwd().readFileAlloc(allocator, "input.txt", 4096);
    defer allocator.free(data);

    var row: i32 = 0;
    var col: i32 = 0;

    const antenna_point = std.ArrayList([2]i32);
    var antennas = std.hash_map.AutoHashMap(u8, antenna_point).init(allocator);

    var is_antenna: bool = undefined;
    for (data) |c| {
        is_antenna = switch (c) {
            'a'...'z', 'A'...'Z', '0'...'9' => true,
            else => false,
        };

        col += 1;
        if (c == '\n') {
            row += 1;
            col = 0;
        }

        if (!is_antenna) continue;
        print("Found antenna: {c} at {}-{} \n", .{ c, row, col });

        const antenna = try antennas.getOrPut(c);

        if (!antenna.found_existing) {
            antenna.value_ptr.* = antenna_point.init(allocator);
        }

        try antenna.value_ptr.*.append(.{ row, col });
    }

    var it = antennas.iterator();

    while (it.next()) |entry| {
        print("{c} -- {any}\n", .{ entry.key_ptr.*, entry.value_ptr.*.items });
    }
}
