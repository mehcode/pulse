const Memory = @import("operands/memory.zig").Memory;
const Register = @import("operands/register.zig").Register;

/// Either a CPU register or a memory addressing mode.
pub const RegisterOrMemory = union(enum) {
    register: Register,
    memory: Memory,
};
