// NOTE: I think that I did really bad on this one

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

    {
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
    }

    var pos = array.len - 1;
    while (pos > 0) {
        if (array[pos] == -1) {
            pos -= 1;
            continue;
        }

        const start = pos;
        const char = array[start];

        var i: usize = 0;
        while (pos - i > 0 and array[start - i] == char) : (i += 1) continue;

        pos -= i;

        const length: usize = start - pos;

        var it = std.mem.window(i64, array, length, 1);
        var pat_buf: [256]i64 = undefined;
        const pat: []const i64 = pat_buf[0..length];
        for (pat_buf[0..length]) |*slot| slot.* = -1;

        var j: usize = 0;
        while (it.next()) |window| {
            if (std.mem.eql(i64, window, pat)) {
                break;
            }

            j += 1;
        }

        if (j + length > array.len) continue;
        if (j > pos) continue;

        for (0..length) |idx| {
            array[j + idx] = char;
        }

        for (pos..pos + length) |idx| {
            array[idx + 1] = -1;
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
