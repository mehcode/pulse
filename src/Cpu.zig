//! Holds the state of the CPU registers.

const std = @import("std");
const Bus = @import("Bus.zig");
const Instruction = @import("Instruction.zig");

const Cpu = @This();

/// Program Counter (PC)
///
/// Holds the address of the next instruction to be executed.
///
pc: u16 = 0,

/// Processor (P) Status
p: u8 = 0,

/// Accumulator (A)
///
/// The primary register for arithmetic and logic operations.
///
/// Most ALU operations (addition, subtraction, bitwise operations, etc.)
/// use the accumulator as an operand and store results back to it.
/// While the index registers `X` and `Y`
/// support some operations, the accumulator has the richest set of
/// available instructions.
///
a: u8 = 0,

/// Resets the CPU state, setting the program counter to the address stored at
/// the reset vector (`0xFFFC`).
pub fn reset(self: *Cpu, bus: *Bus) void {
    self.pc = bus.readWord(0xfffc);
}

/// Runs the `Cpu` for one instruction.
/// Yields cycles back to the `SystemBus` to allow other components to run.
pub fn run(self: *Cpu, bus: *Bus) void {
    const pc = self.pc;
    const opcode = bus.readByteAndAdvance(&self.pc);

    var instruction = Instruction.decode(opcode) orelse {
        std.debug.panic("unknown opcode ${X:02} at ${X:04}", .{ opcode, pc });
    };

    instruction.operation(self, bus);
}
