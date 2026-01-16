const std = @import("std");
const builtin = @import("builtin");
const Arguments = @import("Arguments.zig");
const System = @import("System.zig");

pub fn main(init: std.process.Init.Minimal) !void {
    var threaded: std.Io.Threaded = .init_single_threaded;
    defer threaded.deinit();

    const io = threaded.ioBasic();

    // choose allocator based on build mode
    // in debug mode, use the debug allocator to help catch memory issues
    const use_debug_allocator = builtin.mode == .Debug;

    if (use_debug_allocator) {
        var debug = std.heap.DebugAllocator(.{}).init;
        defer _ = debug.deinit();

        try run(init, io, debug.allocator());
    } else {
        try run(init, io, std.heap.smp_allocator);
    }
}

fn run(init: std.process.Init.Minimal, io: std.Io, allocator: std.mem.Allocator) !void {
    // parse arguments from the command line
    var args = try Arguments.parse(allocator, init.args);
    defer args.deinit();

    // open the game ROM specified in the arguments
    var system = System{};
    defer system.deinit(io);

    try system.open(io, args.game);

    system.run();
}
