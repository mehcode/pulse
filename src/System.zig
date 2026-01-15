//! Container that coordinates components of the NES.
//! The System struct represents a complete NES emulator instance.
const Cpu = @import("Cpu.zig");
const Bus = @import("Bus.zig");
const Game = @import("Game.zig");

const System = @This();

/// The 6502-compatible CPU that executes program instructions.
cpu: Cpu = .{},

/// The system bus connecting the CPU to memory and I/O components.
bus: Bus = .{},

/// Cleans up resources used by the system.
/// Deinitializes the bus, which closes any loaded game.
pub fn deinit(self: *System) void {
    self.bus.deinit();
}

/// Opens and loads a game from the given file path.
///
/// The game file must be in iNES format. After loading, the CPU is
/// automatically reset by calling the `/RESET` vector, which sets the
/// program counter to the address specified in the cartridge's reset vector
/// at `$FFFC` - `$FFFD`.
///
pub fn open(self: *System, path: []const u8) !void {
    self.bus.game = try Game.open(path);

    // after when opening a game
    // re-initialize the CPU by calling the /RESET vector
    self.cpu.reset(&self.bus);
}

// TODO: replace with a more involved system when we start getting into frame buffers
/// Runs the system for one CPU instruction.
pub fn run(self: *System) void {
    self.cpu.run(&self.bus);
}
