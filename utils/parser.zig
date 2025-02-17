const Parser = struct {
    pos: usize = 0,
    start: usize = 0,
    input: []const u8,

    fn init(input: []const u8) Parser {
        return .{ .input = input };
    }

    fn peek(self: *Parser) u8 {
        if (self.pos >= self.input.len - 1) unreachable;
        return self.input[self.pos];
    }

    fn advance(self: *Parser) void {
        self.pos += 1;
    }

    fn set_start(self: *Parser) void {
        self.start = self.pos;
    }

    fn is_at_end(self: *Parser) bool {
        return self.pos >= self.input.len - 1;
    }
    fn is_at_number(self: *Parser) bool {
        const c = self.input[self.pos];
        return c >= '0' and c <= '9';
    }
};
