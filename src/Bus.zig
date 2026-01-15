//! The interconnecting bus for the NES system.
//!
//! The bus is the central component that connects the CPU to all other parts
//! of the NES, routing memory reads and writes to the appropriate hardware components.
//! It implements the NES CPU memory map, which spans from $0000 to $FFFF (64kB address space).
//!

const std = @import("std");
const Game = @import("Game.zig");

const Bus = @This();

/// Work RAM (WRAM) - 2kB of general purpose internal memory.
wram: *[0x800]u8 = undefined,

/// The currently loaded game.
///
/// Contains the game's ROM data (PRG-ROM, CHR-ROM) and mapper configuration.
/// When `null`, no game is loaded. The bus needs a valid game to handle
/// reads and writes to cartridge space ($4020-$FFFF).
///
game: ?Game = null,

/// Cleans up resources used by the bus.
/// If a game is loaded, closes it and clears the game reference.
pub fn deinit(self: *Bus) void {
    if (self.game) |*game| {
        game.close();
    }

    self.game = null;
}

/// Yields control back to the System for the time span of a single CPU cycle.
/// This is used to allow the system to perform other operations such as rendering
/// the PPU, handling input, etc.
pub fn yieldCycle(self: *Bus) void {
    // TODO: implement cycle yielding
    _ = self;
}

/// Reads a byte from the specified address on the bus.
pub fn readByte(self: *Bus, address: u16) u8 {
    // yield before the memory access
    self.yieldCycle();

    switch (address) {
        0x2000...0x3FFF => {
            // PPU registers (0x2000..=0x2007) mirrored every 8 bytes up to 0x3FFF
            // TODO: implement PPU register reads with proper side effects
            return 0;
        },

        else => return self.peekByte(address),
    }
}

/// Reads a byte from the specified address on the bus, without side effects.
pub fn peekByte(self: *const Bus, address: u16) u8 {
    switch (address) {
        0x0000...0x1FFF => {
            // Work RAM (2 KiB) mirrored every 0x800 bytes across 0x0000..0x1FFF
            return self.wram[address & 0x07FF];
        },

        0x8000...0xFFFF => {
            if (self.game) |*game| {
                // iNES mapper 0 logic: PRG-ROM at 0x8000..=0xFFFF
                var rom_address: u16 = address -% 0x8000;

                if (game.prg_rom.len <= 0x4000) {
                    // 16 KiB PRG-ROM mirrored in upper bank
                    rom_address &= 0x3FFF;
                }

                return game.prg_rom[rom_address];
            }

            // No game loaded; fall through to warning
            std.debug.print("warn: peek from cartridge space without game at ${X:04}\n", .{address});
            return 0;
        },

        else => {
            std.debug.print("warn: unhandled peek from address ${X:04}\n", .{address});
            return 0;
        },
    }
}

/// Reads a byte from `address` and then increment `address` by 1.
pub fn readByteAndAdvance(self: *Bus, address: *u16) u8 {
    const value = self.readByte(address.*);
    address.* = address.* +% 1;

    return value;
}

/// Reads a word from the specified address on the bus.
pub fn readWord(self: *Bus, address: u16) u16 {
    const lo = @as(u16, self.readByte(address));
    const hi = @as(u16, self.readByte(address +% 1));

    return (hi << 8) | lo;
}

/// Writes a byte to the specified address on the bus.
pub fn writeByte(self: *Bus, address: u16, value: u8) void {
    // TODO: implement write logic
    _ = self;
    _ = address;
    _ = value;
}
