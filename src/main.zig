const std = @import("std");
const builtin = @import("builtin");
const Arguments = @import("Arguments.zig");
const System = @import("System.zig");

pub fn main() !void {
    // choose allocator based on build mode
    // in debug mode, use the debug allocator to help catch memory issues
    const use_debug_allocator = builtin.mode == .Debug;

    if (use_debug_allocator) {
        var debug = std.heap.DebugAllocator(.{}).init;
        defer _ = debug.deinit();

        try run(debug.allocator());
    } else {
        try run(std.heap.smp_allocator);
    }
}

fn run(allocator: std.mem.Allocator) !void {
    // parse arguments from the command line
    var args = try Arguments.parse(allocator);
    defer args.deinit();

    // open the game ROM specified in the arguments
    var system = System{};
    defer system.deinit();

    try system.open(args.game);

    system.run();
}
