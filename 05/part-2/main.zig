const std = @import("std");

fn read_file_line_by_line(
    allocator: std.mem.Allocator,
    ordering_rules: *std.ArrayList([]isize),
    pages_to_produce: *std.ArrayList([]isize),
) !void {
    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();
    const reader = file.reader();

    var line_buf = std.ArrayList(u8).init(allocator);
    defer line_buf.deinit();

    var is_second_part = false;

    while (true) {
        reader.readUntilDelimiterArrayList(&line_buf, '\n', 1024 * 1024) catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };

        if (line_buf.items.len == 0) {
            is_second_part = true;
            continue;
        }

        switch (is_second_part) {
            false => try parse_ordering_rule(allocator, line_buf.items, ordering_rules),
            true => try parse_page_to_produce(allocator, line_buf.items, pages_to_produce),
        }

        line_buf.clearRetainingCapacity();
    }
}

fn parse_ordering_rule(
    allocator: std.mem.Allocator,
    line: []const u8,
    ordering_rules: *std.ArrayList([]isize),
) !void {
    var input_it = std.mem.splitScalar(u8, line, '|');
    var ordering_rule_numbers = try allocator.alloc(isize, 2);

    var i: usize = 0;
    while (input_it.next()) |number_ascii| : (i += 1) {
        ordering_rule_numbers[i] = try std.fmt.parseInt(isize, number_ascii, 10);
    }

    try ordering_rules.append(ordering_rule_numbers);
}

fn parse_page_to_produce(
    allocator: std.mem.Allocator,
    line: []const u8,
    pages_to_produce: *std.ArrayList([]isize),
) !void {
    var input_it = std.mem.splitScalar(u8, line, ',');
    var page_to_produce_numbers = std.ArrayList(isize).init(allocator);

    while (input_it.next()) |number_ascii| {
        try page_to_produce_numbers.append(try std.fmt.parseInt(isize, number_ascii, 10));
    }

    try pages_to_produce.append(page_to_produce_numbers.items);
}

fn remove_at(
    comptime T: type,
    allocator: *const std.mem.Allocator,
    slice: []T,
    index: usize,
) ![]T {
    var new_slice = try allocator.alloc(T, slice.len - 1);

    if (index > 0) @memcpy(new_slice[0..index], slice[0..index]);
    if (index + 1 < slice.len) @memcpy(new_slice[index..], slice[index + 1 ..]);

    return new_slice;
}

// NOTE: Using a dictionnary would be a lot easier (and faster), but its enough
// std-learning for the day.
pub fn get_value_from_page(
    allocator: *const std.mem.Allocator,
    page: []isize,
    ordering_rules: [][]isize,
) !isize {
    var is_sequence_valid = true;

    var i: usize = 0;
    while (i < page.len) : (i += 1) {
        const following_numbers = page[i + 1 ..];
        var is_number_valid = true;

        for (following_numbers) |number| {
            var is_following_number_valid = false;

            for (ordering_rules) |ordering_rule| {
                if (std.mem.eql(isize, &[_]isize{ page[i], number }, ordering_rule)) {
                    is_following_number_valid = true;
                }
            }

            if (!is_following_number_valid) is_number_valid = false;
        }

        if (!is_number_valid) is_sequence_valid = false;
    }

    if (is_sequence_valid) return 0;

    var new_page = try allocator.alloc(isize, page.len);

    i = 0;
    while (i < page.len) : (i += 1) {
        const number = page[i];
        const other_numbers = try remove_at(isize, allocator, page, i);

        var counter: usize = 0;
        for (other_numbers) |other_number| {
            var is_in_order = false;

            for (ordering_rules) |ordering_rule| {
                if (std.mem.eql(isize, &[_]isize{ number, other_number }, ordering_rule))
                    is_in_order = true;
            }

            if (is_in_order)
                counter += 1;
        }

        new_page[new_page.len - 1 - counter] = number;
    }

    return new_page[(page.len - 1) / 2];
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var ordering_rules_array = std.ArrayList([]isize).init(allocator);
    var pages_to_produce_array = std.ArrayList([]isize).init(allocator);
    try read_file_line_by_line(allocator, &ordering_rules_array, &pages_to_produce_array);
    const ordering_rules = ordering_rules_array.items;
    const pages_to_produce = pages_to_produce_array.items;

    var sum: isize = 0;
    for (pages_to_produce) |page| sum += try get_value_from_page(&allocator, page, ordering_rules);

    std.debug.print("Sum: {}\n", .{sum});
}
