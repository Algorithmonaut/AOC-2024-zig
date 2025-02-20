// WARN: I need to get used to array[y][x], this is hard rn.

const std = @import("std");

const Guard = struct {
    position: [2]isize,
    pointing: enum { up, right, down, left },
    max_pos: [2]isize, // NOTE: equal to [len(line), len(column)]
    occupied_pos: std.AutoHashMap([2]isize, void),

    fn init(allocator: std.mem.Allocator) !Guard {
        return Guard{
            .position = .{ 0, 0 },
            .pointing = .up,
            .max_pos = undefined,
            .occupied_pos = std.AutoHashMap([2]isize, void).init(allocator),
        };
    }

    fn advance(self: *Guard, obstacles_set: *std.AutoHashMap([2]isize, void)) !bool {
        const relative_movements: [4][2]isize = .{
            .{ -1, 0 },
            .{ 0, 1 },
            .{ 1, 0 },
            .{ 0, -1 },
        };

        const pointing_int = @intFromEnum(self.pointing);
        const relative_movement = relative_movements[pointing_int];

        const new_pos: [2]isize = .{
            self.position[0] + relative_movement[0],
            self.position[1] + relative_movement[1],
        };

        if (obstacles_set.contains(new_pos)) {
            const next_pointing_int = (@as(u3, pointing_int) + 1) % 4;
            self.pointing = @enumFromInt(next_pointing_int);
            return true;
        }

        if (self.position[0] < 0 or
            self.position[1] < 0 or
            self.position[0] >= self.max_pos[0] or
            self.position[1] >= self.max_pos[1]) return false;

        try self.occupied_pos.put(self.position, {});
        self.position = new_pos;

        return true;
    }
};

fn populate_set_and_guard_from_input(
    set: *std.AutoHashMap([2]isize, void),
    guard: *Guard,
) !void {
    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var reader = buf_reader.reader();

    var row: isize = 0;
    var col: isize = 0;

    while (true) {
        const byte = reader.readByte() catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };

        if (byte == '\n') {
            guard.max_pos[1] = col;
            row += 1;
            col = 0;
            continue;
        }

        if (byte == '#') try set.put(.{ row, col }, {});
        if (byte == '^') guard.position = .{ row, col };

        col += 1;
    }

    guard.max_pos[0] = row;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa_allocator = gpa.allocator();
    var arena = std.heap.ArenaAllocator.init(gpa_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var guard = try Guard.init(allocator);
    var obstacle_positions_set = std.AutoHashMap([2]isize, void).init(allocator);

    try populate_set_and_guard_from_input(&obstacle_positions_set, &guard);

    var iterator = obstacle_positions_set.keyIterator();
    while (iterator.next()) |_| {}

    while (try guard.advance(&obstacle_positions_set)) {
        continue;
    }

    std.debug.print("Counter: {}\n", .{guard.occupied_pos.count()});
}
