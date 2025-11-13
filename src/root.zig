//! By convention, root.zig is the root source file when making a library.
const std = @import("std");

const validationFormats = enum {
    digits,
};

// in args, i'd rather support something like ?anytype but that ain't possible
pub fn bufferedPrint(comptime bytes: []const u8, args: anytype) !void {
    // Stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    try stdout.print(bytes, args);

    try stdout.flush(); // Don't forget to flush!
}

pub fn bufferedRead(stdin_buffer: []u8, allocator: std.mem.Allocator) ![]u8 {
    var stdin_reader = std.fs.File.stdin().reader(stdin_buffer);
    const stdin = &stdin_reader.interface;
    const read = try stdin.takeDelimiterExclusive('\n');
    const output_read = try allocator.alloc(u8, read.len);
    @memcpy(output_read, read);
    return output_read;
}

pub fn validateInput(inputToValidate: []const u8, receivedValidationFormat: []const u8) !bool {
    var valid = true;
    const usableValidationFormat = std.meta.stringToEnum(validationFormats, receivedValidationFormat) orelse {
        return error.invalidChoice;
    };
    switch (usableValidationFormat) {
        .digits => {
            for (inputToValidate) |character| {
                if (!std.ascii.isDigit(character)) {
                    valid = false;
                    break;
                }
            }
        },
    }
    return valid;
}
pub fn add(a: i32, b: i32) i32 {
    return a + b;
}

test "basic add functionality" {
    try std.testing.expect(add(3, 7) == 10);
}
