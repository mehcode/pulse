//! A game for the NES, with its source file locked and memory-mapped.
//! Provides safe and efficient access to the game data.

const std = @import("std");

const Game = @This();

/// Retain a handle to the file to keep it open while memory-mapped.
_file: std.Io.File,

/// Memory-mapped representation of the source file.
_rom: []align(std.heap.page_size_min) u8,

/// PRG-ROM data, borrowed from the memory-mapped file.
prg_rom: []const u8,

/// CHR-ROM data, borrowed from the memory-mapped file.
chr_rom: []const u8,

/// Opens a game from the specified file path.
/// Currently, only supports the most basic iNES 1.x format.
pub fn open(io: std.Io, path: []const u8) !Game {
    const cwd = std.Io.Dir.cwd();

    const file = try cwd.openFile(io, path, .{
        .mode = .read_only,
    });

    // read in the 16-byte iNES header
    // https://www.nesdev.org/wiki/NES_2.0
    // https://www.nesdev.org/wiki/INES
    var header: [16]u8 = undefined;
    const n = try file.readPositionalAll(io, &header, 0);
    if (n != header.len) {
        return error.GameInvalidHeader;
    }

    // validate the iNES identifier
    if (!std.mem.eql(u8, header[0..4], "NES\x1a")) {
        return error.GameInvalidIdentifier;
    }

    // PRG-ROM size is stored in 16 KB units (at byte 4)
    const prg_rom_size = @as(u64, header[4]) * 16_384;

    // CHR-ROM size is stored in 8 KB units (at byte 5)
    const chr_rom_size = @as(u64, header[5]) * 8_192;

    // TODO: read in mapper number
    // TODO: read in PRG-RAM size
    // TODO: read in more information

    // TODO: add alternative method for windows support
    const size = prg_rom_size + chr_rom_size;

    const rom = try std.posix.mmap(
        null,
        size,
        .{ .READ = true },
        .{ .TYPE = .SHARED },
        file.handle,
        0,
    );

    return .{
        ._file = file,
        ._rom = rom,
        .prg_rom = rom[16 .. prg_rom_size + 16],
        .chr_rom = rom[16 + prg_rom_size ..],
    };
}

/// Closes the game, unmapping the ROM from memory and closing the file.
pub fn close(self: *Game, io: std.Io) void {
    std.posix.munmap(self._rom);
    self._file.close(io);
}
