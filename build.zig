const std = @import("std");
const zlinter = @import("zlinter");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{
        .preferred_optimize_mode = .ReleaseSafe,
    });

    const mod = b.addModule("pulse", .{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{
        .name = "pulse",
        .root_module = mod,
    });

    b.installArtifact(exe);

    buildFmt(b);
    buildCheck(b, mod);
    buildRun(b, exe);
    buildTest(b, exe);
    buildLint(b);
}

/// Check to ensure the executable compiles.
/// Used for as-you-type verification in IDEs.
fn buildCheck(b: *std.Build, mod: *std.Build.Module) void {
    const step = b.step("check", "Check if build compiles.");

    step.dependOn(&b.addExecutable(.{
        .name = "pulse",
        .root_module = mod,
    }).step);
}

/// Build and run the executable.
fn buildRun(b: *std.Build, exe: *std.Build.Step.Compile) void {
    const step = b.step("run", "Run.");
    const run = b.addRunArtifact(exe);

    if (b.args) |args| {
        run.addArgs(args);
    }

    step.dependOn(&run.step);
    run.step.dependOn(&exe.step);
}

/// Run all tests.
fn buildTest(b: *std.Build, exe: *std.Build.Step.Compile) void {
    const step = b.step("test", "Run tests.");

    step.dependOn(buildTestFmt(b));
    step.dependOn(buildTestUnit(b, exe));
}

/// Collect and run unit tests.
fn buildTestUnit(b: *std.Build, exe: *std.Build.Step.Compile) *std.Build.Step {
    const step = b.step("test-unit", "Run unit tests.");

    step.dependOn(&b.addRunArtifact(b.addTest(.{
        .name = "pulse_tests_unit",
        .root_module = exe.root_module,
    })).step);

    return step;
}

const fmt_include = &.{
    "src",
    "build.zig",
    "build.zig.zon",
};

/// Format source files.
fn buildFmt(b: *std.Build) void {
    const step = b.step("fmt", "Format source code.");

    step.dependOn(&b.addFmt(.{
        .paths = fmt_include,
    }).step);
}

/// Check source files for formatting.
fn buildTestFmt(b: *std.Build) *std.Build.Step {
    const step = b.step("test-fmt", "Check formatting on source code.");

    step.dependOn(&b.addFmt(.{
        .paths = fmt_include,
        .check = true,
    }).step);

    return step;
}

/// Lint source code.
fn buildLint(b: *std.Build) void {
    const step = b.step("lint", "Lint source code.");

    step.dependOn(step: {
        var builder = zlinter.builder(b, .{});

        builder.addRule(.{ .builtin = .file_naming }, .{});
        builder.addRule(.{ .builtin = .function_naming }, .{});
        builder.addRule(.{ .builtin = .max_positional_args }, .{});
        builder.addRule(.{ .builtin = .no_comment_out_code }, .{});
        builder.addRule(.{ .builtin = .no_deprecated }, .{});
        builder.addRule(.{ .builtin = .no_empty_block }, .{});
        builder.addRule(.{ .builtin = .no_hidden_allocations }, .{});
        builder.addRule(.{ .builtin = .no_literal_only_bool_expression }, .{});
        builder.addRule(.{ .builtin = .no_orelse_unreachable }, .{});
        builder.addRule(.{ .builtin = .no_panic }, .{});
        builder.addRule(.{ .builtin = .no_swallow_error }, .{});
        builder.addRule(.{ .builtin = .no_unused }, .{});
        builder.addRule(.{ .builtin = .require_braces }, .{});
        builder.addRule(.{ .builtin = .require_errdefer_dealloc }, .{});

        break :step builder.build();
    });
}
