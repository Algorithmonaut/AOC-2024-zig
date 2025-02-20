const std = @import("std");

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
        if (byte == '^') {
            guard.position = .{ row, col };
            guard.default_position = .{ row, col };
        }

        col += 1;
    }

    guard.max_pos[0] = row;
    guard.max_count = guard.max_pos[0] * guard.max_pos[1];
}

const AdvanceState = union(enum) {
    in_map: bool,
    hit_obstruction_direction: Direction,
};

const Direction = enum { up, right, down, left };

const Guard = struct {
    position: [2]isize,
    pointing: Direction,
    max_pos: [2]isize,
    advance_state: AdvanceState,
    default_position: [2]isize,
    counter: isize,
    max_count: isize,

    fn init() !Guard {
        return Guard{
            .position = .{ 0, 0 },
            .default_position = .{ 0, 0 },
            .pointing = .up,
            .max_pos = undefined,
            .advance_state = .{ .in_map = true },
            .counter = 0,
            .max_count = 0,
        };
    }

    fn is_stuck_in_loop(
        self: *Guard,
        obstacles_set: *std.AutoHashMap([2]isize, void),
        obstruction_pos: [2]isize,
    ) !bool {
        var obstruction_hit_direction: ?Direction = null;

        while (true) {
            if (self.counter >= self.max_count) return true;

            const result = try self.advance(obstacles_set, obstruction_pos);

            switch (result) {
                .in_map => |flag| {
                    if (flag) {
                        continue;
                    } else {
                        return false;
                    }
                },
                .hit_obstruction_direction => |dir| {
                    if (obstruction_hit_direction) |direction| {
                        if (dir == direction) {
                            return true;
                        }
                    } else {
                        obstruction_hit_direction = dir;
                    }
                },
            }
        }
        return false;
    }

    fn advance(
        self: *Guard,
        obstacles_set: *std.AutoHashMap([2]isize, void),
        obstruction_pos: [2]isize,
    ) !AdvanceState {
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

        if (obstruction_pos[0] == new_pos[0] and obstruction_pos[1] == new_pos[1]) {
            const pointing = self.pointing;
            const next_pointing_int = (@as(u3, pointing_int) + 1) % 4;
            self.pointing = @enumFromInt(next_pointing_int);
            return AdvanceState{ .hit_obstruction_direction = pointing };
        }

        if (obstacles_set.contains(new_pos)) {
            const next_pointing_int = (@as(u3, pointing_int) + 1) % 4;
            self.pointing = @enumFromInt(next_pointing_int);
            return .{ .in_map = true };
        }

        if (self.position[0] < 0 or
            self.position[1] < 0 or
            self.position[0] >= self.max_pos[0] or
            self.position[1] >= self.max_pos[1]) return .{ .in_map = false };

        self.position = new_pos;
        self.counter += 1;

        return .{ .in_map = true };
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa_allocator = gpa.allocator();
    var arena = std.heap.ArenaAllocator.init(gpa_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var guard = try Guard.init();
    var obstacle_positions_set = std.AutoHashMap([2]isize, void).init(allocator);

    try populate_set_and_guard_from_input(&obstacle_positions_set, &guard);

    var counter: usize = 0;

    var row: isize = 0;
    while (row < guard.max_pos[0]) : (row += 1) {
        var col: isize = 0;
        while (col < guard.max_pos[1]) : (col += 1) {
            const obstruction_pos: [2]isize = .{ row, col };
            if (std.mem.eql(isize, &obstruction_pos, &guard.default_position)) continue;
            if (try guard.is_stuck_in_loop(&obstacle_positions_set, obstruction_pos)) {
                counter += 1;
            }
            guard.position = guard.default_position;
            guard.pointing = .up;
            guard.counter = 0;
        }
    }

    std.debug.print("Counter: {}\n", .{counter});
}
