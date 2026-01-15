const Cpu = @import("Cpu.zig");
const Bus = @import("Bus.zig");
const Memory = @import("operands/memory.zig").Memory;
const Register = @import("operands/register.zig").Register;

/// Clear Decimal Mode (`CLD`)
///
/// ```text
/// D <- 0
/// ```
///
/// Clears the decimal mode flag (disables BCD arithmetic).
/// This has no affect on the 2A03.
///
/// - `D`: Cleared.
///
pub fn cld(cpu: *Cpu, _: *Bus) void {
    // TODO: declare `p` as a bit set
    cpu.p &= ~@as(u8, 0b0000_0100);
}

/// Bit Test (`BIT`)
///
/// ```text
/// A & $
/// N <- $.7
/// V <- $.6
/// ```
///
/// Performs `A & $` to update the zero flag without changing `A`.
/// Copies bit 7 and bit 6 of the memory value into `N` and `V` respectively.
///
/// - `Z`: Set if `A & $` is zero.
/// - `V`: Set to bit 6 of `$`.
/// - `N`: Set to bit 7 of `$`.
///
pub fn bit(comptime operand: Memory, cpu: *Cpu, bus: *Bus) void {
    _ = operand;
    _ = cpu;
    _ = bus;

    // TODO: implement BIT
}

/// Load (`LDA`, `LDX`, `LDY`)
///
/// ```text
/// $1 <- $2
/// ```
///
/// Loads a byte of memory into a register,
/// setting the zero and negative flags as appropriate.
///
/// - `Z`: Set if result is zero.
/// - `N`: Set if result is negative.
///
pub fn load(comptime src: Memory, comptime dst: Register, cpu: *Cpu, bus: *Bus) void {
    _ = src;
    _ = dst;
    _ = cpu;
    _ = bus;

    // TODO: implement LOAD
}
