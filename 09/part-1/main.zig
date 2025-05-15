const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    var da = std.heap.DebugAllocator(.{}){};
    const allocator = da.allocator();

    var data = try std.fs.cwd().readFileAlloc(allocator, "input.txt", 16_777_216);
    data.len -= 1;

    for (data, 0..) |c, i| {
        data[i] = c - 48;
    }

    const array_length = blk: {
        var total: usize = 0;
        for (data) |v| {
            total += v;
        }

        break :blk total;
    };

    var array = try allocator.alloc(i64, array_length);
    defer allocator.free(array);

    var is_file = true;
    var id: i64 = 0;

    var pos: usize = 0;
    var new_pos: usize = 0;

    for (data) |v| {
        pos = new_pos;
        new_pos = pos + v;

        if (is_file) {
            for (pos..new_pos) |i| {
                array[i] = id;
            }
            id += 1;
        } else {
            for (pos..new_pos) |i| {
                array[i] = -1;
            }
        }

        is_file = !is_file;
    }

    {
        var i: usize = array.len - 1;
        while (i > 0) : (i -= 1) {
            if (array[i] != -1) {
                for (array, 0..) |v, j| {
                    if (v == -1) {
                        array[j] = array[i];
                        array[i] = -1;
                        break;
                    }

                    if (j >= i) break;
                }
            }
        }
    }

    var sum: i64 = 0;

    var i: i64 = 0;
    while (i < array.len) : (i += 1) {
        if (array[@intCast(i)] == -1) continue;
        sum += i * array[@intCast(i)];
    }

    print("Sum: {}", .{sum});
}
