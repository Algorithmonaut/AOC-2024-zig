pub const Parser = struct {
    pos: usize = 0,
    start: usize = 0,
    input: []const u8,

    pub fn init(input: []const u8) Parser {
        return .{ .input = input };
    }

    pub fn peek(self: *Parser) u8 {
        if (self.pos >= self.input.len - 1) unreachable;
        return self.input[self.pos];
    }

    pub fn lookahead(self: *Parser) u8 {
        if (self.pos >= self.input.len - 2) unreachable;
        return self.input[self.pos + 1];
    }

    pub fn advance(self: *Parser) void {
        self.pos += 1;
    }

    // pub fn set_start(self: *Parser, pos: ?usize) void {
    //     self.start = pos orelse self.pos;
    // }

    pub fn set_start(self: *Parser) void {
        self.start = self.pos;
    }

    pub fn set_pos(self: *Parser, pos: usize) void {
        self.pos = pos;
    }

    pub fn is_at_end(self: *Parser) bool {
        return self.pos >= self.input.len - 1;
    }

    pub fn next_at_end(self: *Parser) bool {
        return self.pos + 1 >= self.input.len - 1;
    }

    pub fn is_at_number(self: *Parser) bool {
        const c = self.input[self.pos];
        return c >= '0' and c <= '9';
    }
};
