const std = @import("std");
const zpm = @import("zpm");
const builtin = @import("builtin");

pub fn main() !void {
    // Prints to stderr, ignoring potential errors.
    var debug_allocator: std.heap.DebugAllocator(.{}) = .init;
    const gpa = switch (builtin.mode) {
        .Debug, .ReleaseSafe => debug_allocator.allocator(),
        .ReleaseFast, .ReleaseSmall => std.heap.smp_allocator,
    };
    defer if (builtin.mode == .Debug or builtin.mode == .ReleaseSafe) {
        _ = debug_allocator.deinit();
    };
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
    var stdin_buffer: [1024]u8 = undefined;
    const initMessages = .{
        "Welcome to zimple-passphrase-manager",
        "This just... generates a passphrase currently",
    };

    inline for (initMessages) |message| {
        //_ = try std.fs.File.stdout().write(message ++ "\n");
        // turn index into []u8
        // This creates a value that holds an array of size 1 of the index value
        // there's probably a better way to handle this
        //const indexStr = [1]u8{@as(u8, index)};
        try zpm.bufferedPrint(message, .{});
    }
    var passphraseLength: []u8 = undefined;
    var typoificationRead: []u8 = undefined;

    // I need these because when I use the bufferedRead, I allocate
    // thus, at the end, I need to free the allocated memory
    defer gpa.free(passphraseLength);
    defer gpa.free(typoificationRead);

    //var typoification: bool = false;
    const setupMessages = .{
        // Keep in mind the {} means a value must be filled in
        "How many words long should the passphrase be?",
        "Requested length: ",
        "Do you want to typoify some words of the passphrase? Currently, there's a 50% chance for a word in the passphrase to be typoified.",
    };

    inline for (setupMessages, 0..) |message, index| {
        //_ = try std.fs.File.stdout().write(message ++ "\n");
        // turn index into []u8
        // This creates a value that holds an array of size 1 of the index value
        // there's probably a better way to handle this
        try zpm.bufferedPrint(message, .{});
        switch (index) {
            1 => {
                var anotherBuffer: [1024]u8 = undefined;
                passphraseLength = try zpm.bufferedRead(&anotherBuffer, gpa);
            },
            2 => {
                typoificationRead = try zpm.bufferedRead(&stdin_buffer, gpa);
                //if (typoificationRead[0] == 'Y') {
                //    typoification = true;
                //}
            },
            else => try zpm.bufferedPrint("oops", .{}),
        }
        try zpm.bufferedPrint("\n", .{});
    }

    // const finalConfigMessages = .{
    //     // Keep in mind the {} means a value must be filled in

    //     "Requested passphrase length: {any}",
    //     "Number of words in the dictionary: {any}",
    //     "Typoification: {bool}",
    // };

    // Our configuration values
    const configValues = .{ passphraseLength, typoificationRead };
    inline for (configValues) |value| {
        try zpm.bufferedPrint("Configuration Value: {s}\n", .{value});
    }
}

test "simple test" {
    const gpa = std.testing.allocator;
    var list: std.ArrayList(i32) = .empty;
    defer list.deinit(gpa); // Try commenting this out and see if zig detects the memory leak!
    try list.append(gpa, 42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

test "fuzz example" {
    const Context = struct {
        fn testOne(context: @This(), input: []const u8) anyerror!void {
            _ = context;
            // Try passing `--fuzz` to `zig build test` and see if it manages to fail this test case!
            try std.testing.expect(!std.mem.eql(u8, "canyoufindme", input));
        }
    };
    try std.testing.fuzz(Context{}, Context.testOne, .{});
}
