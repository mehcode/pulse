//! Represents command-line arguments for Pulse.

const std = @import("std");

const Arguments = @This();

/// Reference to the argument iterator,
/// used for later deinitialization on Windows.
_iterator: std.process.Args.Iterator,

/// Path to the game file.
game: []const u8,

/// Parses command-line arguments into an Args struct, for Pulse.
pub fn parse(allocator: std.mem.Allocator, args: std.process.Args) !Arguments {
    var iterator = try args.iterateAllocator(allocator);

    // skip the first argument, which is the program name
    _ = iterator.skip();

    var game: ?[]const u8 = null;

    while (iterator.next()) |arg| {
        if (std.mem.startsWith(u8, arg, "-")) {
            // TODO: handle flags
            continue;
        }

        if (game != null) {
            return error.GameAlreadyDefined;
        }

        game = arg;
    }

    return .{
        ._iterator = iterator,
        .game = game orelse {
            return error.GameMissing;
        },
    };
}

/// Deinitializes the Arguments struct, freeing any resources it holds.
pub fn deinit(self: *Arguments) void {
    self._iterator.deinit();
}
