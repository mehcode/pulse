//! Represents a single 6502 CPU instruction.
//!
//! Defines the instruction set for the 6502 CPU used in the NES.
//! Each instruction is mapped to an opcode (0x00-0xFF) in the instruction table.
//!

const Cpu = @import("Cpu.zig");
const Bus = @import("Bus.zig");
const ops = @import("operations.zig");

const Instruction = @This();

/// Human-readable name of the instruction (e.g., "LDA", "BIT", "CLD")
mnemonic: []const u8,

/// Function pointer that executes the instruction's operation.
operation: *const fn (cpu: *Cpu, bus: *Bus) void,

/// Decodes an opcode into an `Instruction`.
/// Returns `null` if the opcode is invalid or unknown.
pub fn decode(opcode: u8) ?Instruction {
    return table[opcode];
}

/// Lookup table mapping opcodes to instructions.
/// Each index represents an opcode (0x00-0xFF), with null representing undefined/illegal opcodes.
///
/// References:
/// - https://www.nesdev.org/wiki/Instruction_reference
/// - https://www.nesdev.org/obelisk-6502-guide/reference.html
/// - https://problemkaputt.de/everynes.htm#cpu65xxmicroprocessor
///
const table: [0xff]?Instruction = blk: {
    var init: [0xff]?Instruction = @splat(null);

    // Load from Memory (LDA, LDX, LDY)
    init[0xa9] = new("LDA", ops.load, .{ .immediate, .a });

    // Bit Test (BIT)
    init[0x24] = new("BIT", ops.bit, .{.absolute});

    // CPU Control
    init[0xd8] = new("CLD", ops.cld, .{});

    break :blk init;
};

/// Creates an `Instruction` with bound operands.
///
/// This function creates an instruction by binding the operands
/// to the operation at compile time, generating a specialized execute function.
///
/// Parameters:
/// - `mnemonic`: The instruction's human-readable name.
/// - `operation`: The (macro) operation function to execute.
/// - `operands`: A tuple of compile-time operands (e.g., addressing mode, register).
///
fn new(mnemonic: []const u8, comptime operation: anytype, comptime operands: anytype) Instruction {
    return .{ .mnemonic = mnemonic, .operation = struct {
        pub fn execute(cpu: *Cpu, bus: *Bus) void {
            @call(.auto, operation, operands ++ .{ cpu, bus });
        }
    }.execute };
}
