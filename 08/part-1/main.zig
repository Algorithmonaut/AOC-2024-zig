const std = @import("std");

const print = std.debug.print;

var width: i32 = undefined;
var height: i32 = undefined;

fn set_antenna_antinodes(
    locations: []const [2]i32,
    antinodes_pos: *std.hash_map.AutoHashMap([2]i32, void),
) !void {
    for (locations) |base_location| {
        for (locations) |other_location| {
            if (std.mem.eql(i32, base_location[0..], other_location[0..]))
                continue;

            // print("Base: {any}, other: {any}\n", .{ base_location, other_location });

            const relative_row = other_location[0] - base_location[0];
            const relative_col = other_location[1] - base_location[1];

            const antinode_pos_row = base_location[0] - relative_row;
            const antinode_pos_col = base_location[1] - relative_col;

            if (antinode_pos_col >= width or antinode_pos_col < 0) continue;
            if (antinode_pos_row >= height or antinode_pos_row < 0) continue;

            // print("There should be an antinode at {} {}\n", .{ antinode_pos_row + 1, antinode_pos_col + 1 });

            try antinodes_pos.put(.{ antinode_pos_row, antinode_pos_col }, {});
        }
    }
}

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

        if (is_antenna) {
            // print("Found antenna: {c} at {}-{} \n", .{ c, row, col });

            const antenna = try antennas.getOrPut(c);

            if (!antenna.found_existing) {
                antenna.value_ptr.* = antenna_point.init(allocator);
            }

            try antenna.value_ptr.*.append(.{ row, col });
        }

        col += 1;
        if (c == '\n') {
            width = col - 1;
            row += 1;
            col = 0;
        }
    }

    height = row;

    var antinodes_pos = std.hash_map.AutoHashMap([2]i32, void).init(allocator);

    var it = antennas.iterator();

    while (it.next()) |entry| {
        try set_antenna_antinodes(entry.value_ptr.items, &antinodes_pos);
    }

    std.debug.print("Count: {}", .{antinodes_pos.count()});
}
