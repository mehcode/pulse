const std = @import("std");

/// Represents command-line arguments for Pulse.
pub const Arguments = struct {
    inner: std.process.ArgIterator,
    game: []const u8,

    /// Parses command-line arguments into an Args struct, for Pulse.
    pub fn parse(allocator: std.mem.Allocator) !Arguments {
        var args = try std.process.argsWithAllocator(allocator);

        // skip the first argument, which is the program name
        _ = args.skip();

        var game: ?[]const u8 = null;

        while (args.next()) |arg| {
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
            .inner = args,
            .game = game orelse {
                return error.GameMissing;
            },
        };
    }

    /// Deinitializes the Arguments struct, freeing any resources it holds.
    pub fn deinit(self: *Arguments) void {
        self.inner.deinit();
    }
};
