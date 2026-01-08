const std = @import("std");

// Although this function looks imperative, it does not perform the build
// directly and instead it mutates the build graph (`b`) that will be then
// executed by an external runner. The functions in `std.Build` implement a DSL
// for defining build steps and express dependencies between them, allowing the
// build runner to parallelize the build automatically (and the cache system to
// know when a step doesn't need to be re-run).
pub fn build(b: *std.Build) void {
    const target = b.resolveTargetQuery(std.Target.Query.parse(
        .{ .arch_os_abi = "wasm32-freestanding" },
    ) catch unreachable);
    const optimize = b.standardOptimizeOption(.{ .preferred_optimize_mode = .ReleaseSmall });
    const mod = b.addExecutable(.{
        .name = "wasm",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/root.zig"),
            .target = target,
            .optimize = optimize,
            .strip = true,
        }),
    });
    mod.entry = .disabled;
    mod.rdynamic = true;
    b.installArtifact(mod);
}
