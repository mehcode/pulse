/// Identifies a single CPU register as an operand.
pub const Register = enum {
    /// Accumulator (A)
    a,

    /// X Index
    x,

    /// Y Index
    y,

    /// Stack (S) Pointer
    s,

    /// Processor (P) Status
    p,
};
