const std = @import("std");
const Arguments = @import("arguments.zig").Arguments;
const Game = @import("game.zig").Game;

pub fn main() !void {
    const gpa = generalPurposeAllocator();

    // parse arguments from the command line
    var args = try Arguments.parse(gpa);
    defer args.deinit();

    // open the game ROM specified in the arguments
    var game = try Game.open(args.game);
    defer game.close();

    std.debug.print("> PRG-ROM {} bytes\n", .{game.prg_rom.len});
    std.debug.print("> CHR-ROM {} bytes\n", .{game.chr_rom.len});
}

/// Decides on a general-purpose allocator, intended for meta allocations
/// such as command-line argument parsing.
fn generalPurposeAllocator() std.mem.Allocator {
    // TODO: look into how conventionally to decide between the smp_allocator and debugAllocator

    var debug = std.heap.DebugAllocator(.{
        .thread_safe = false,
    }){};

    return debug.allocator();
}
