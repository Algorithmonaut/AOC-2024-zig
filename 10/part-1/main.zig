const std = @import("std");
const print = std.debug.print;

var map_width: i64 = 0;
var map_height: i64 = 0;

pub fn main() !void {
    var da = std.heap.DebugAllocator(.{}){};
    const allocator = da.allocator();

    const data = try std.fs.cwd().readFileAlloc(allocator, "input.txt", 16_777_216);

    var slopes_count: usize = 0;
    for (data) |c| {
        if (std.ascii.isDigit(c)) slopes_count += 1;
    }

    var map = try allocator.alloc(i8, slopes_count);

    var idx: usize = 0;
    for (data) |c| {
        if (std.ascii.isDigit(c)) {
            map[idx] = @intCast(c - 48);
            idx += 1;
        } else if (map_width == 0) {
            map_width = @intCast(idx);
        }
    }

    const map_length: i64 = @intCast(map.len);
    map_height = @divTrunc(map_length, map_width);

    var sum: i64 = 0;

    for (0..map.len) |i| {
        if (map[i] == 0) {
            var high_height = std.AutoHashMap(i64, void).init(allocator);
            try find_slopes(allocator, map, @intCast(i), &high_height);

            sum += high_height.count();
        }
    }

    std.debug.print("GRAND TOTAL: {}\n", .{sum});
}

fn find_slopes(
    allocator: std.mem.Allocator,
    map: []i8,
    coor: i64,
    high_height: *std.AutoHashMap(i64, void),
) !void {
    const current_slope = map[@intCast(coor)];
    if (current_slope == 9) {
        try high_height.put(coor, {});
        return;
    }

    var neighbors = [_]i64{
        coor - map_width, // up
        coor + map_width, // down
        coor - 1, // left
        coor + 1, // right
    };

    const col = @rem(coor, map_width);
    const row = @divTrunc(coor, map_width);

    if (row == 0) {
        neighbors[0] = coor;
    } else if (row == map_height - 1) {
        neighbors[1] = coor;
    } else if (col == 0) {
        neighbors[2] = coor;
    } else if (col == map_width - 1) {
        neighbors[3] = coor;
    }

    for (neighbors) |neighbor| {
        if (neighbor >= 0 and neighbor < map.len) {
            if (map[@intCast(neighbor)] == current_slope + 1) {
                try find_slopes(allocator, map, neighbor, high_height);
            }
        }
    }
}
