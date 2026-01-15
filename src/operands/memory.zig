/// Defines how the 6502 processor accesses operands in memory.
///
/// Each operation supports one or more addressing modes. The available modes
/// and their behavior vary by instruction.
///
// https://www.nesdev.org/obelisk-6502-guide/addressing.html
pub const Memory = enum {
    /// Operates on an 8-bit constant value, _immediately_ succeeding the opcode.
    immediate,

    /// Operates on an 8-bit value in the zero page (first 256 bytes of memory),
    /// referenced by an 8-bit index.
    zero_page,

    /// Operates on an 8-bit value in the zero page, indexed by the X register.
    ///
    /// The address is calculated by adding the X register to the 8-bit zero page
    /// address from the instruction. The address calculation wraps around within
    /// the zero page (e.g., `$80 + $FF = $7F`, not `$017F`).
    ///
    zero_page_x,

    /// Operates on an 8-bit value in the zero page, indexed by the Y register.
    ///
    /// The address is calculated by adding the Y register to the 8-bit zero page
    /// address from the instruction. The address calculation wraps around within
    /// the zero page (e.g., `$80 + $FF = $7F`, not `$017F`).
    ///
    zero_page_y,

    /// Operates on a value at a full 16-bit memory address.
    absolute,

    /// Operates on a value at a 16-bit address, indexed by the X register.
    ///
    /// The address is calculated by adding the X register to the 16-bit address
    /// from the instruction (e.g., if X contains `$92`, then `$2000,X` accesses `$2092`).
    ///
    absolute_x,

    /// Operates on a value at a 16-bit address, indexed by the Y register.
    ///
    /// The address is calculated by adding the Y register to the 16-bit address
    /// from the instruction.
    ///
    absolute_y,

    /// Indexed indirect addressing using the X register and a zero page table.
    ///
    /// The 8-bit zero page address from the instruction is added to the X register
    /// (with zero page wrap around) to give the location of the least significant byte
    /// of the target address. Also known as "pre-indexed indirect" or `(d,X)`.
    ///
    indexed_indirect_x,

    /// Indirect indexed addressing using the Y register.
    ///
    /// The instruction contains a zero page location of the least significant byte
    /// of a 16-bit address. The Y register is dynamically added to this address to
    /// generate the actual target address. Also known as "post-indexed indirect" or `(d),Y`
    ///
    indirect_indexed_y,
};
