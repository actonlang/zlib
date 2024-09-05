const builtin = @import("builtin");
const std = @import("std");
const Path = std.Build.LazyPath;

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    var lib = b.addStaticLibrary(.{
        .name = "zlib",
        .target = target,
        .optimize = optimize,
    });

    var source_files = std.ArrayList([]const u8).init(b.allocator);
    defer source_files.deinit();
    var flags = std.ArrayList([]const u8).init(b.allocator);
    defer flags.deinit();

    // const config_header = b.addConfigHeader(
    //     .{
    //         .style = .{ .cmake = b.path("zconf.h.cmakein") }
    //     },
    //     .{
    //         .GLOBAL_CLIENT_CONFIG = "KLLtestzlibclientconfig",
    //     },
    // );
    // lib.addConfigHeader(config_header);

    flags.appendSlice(&.{
        "-Wall",
        "-Wextra",
        "-Wpedantic",
    }) catch unreachable;

    source_files.appendSlice(&.{
        "adler32.c",
        "compress.c",
        "crc32.c",
        "deflate.c",
        "gzclose.c",
        "gzlib.c",
        "gzread.c",
        "gzwrite.c",
        "infback.c",
        "inffast.c",
        "inflate.c",
        "inftrees.c",
        "trees.c",
        "uncompr.c",
        "zutil.c",
    }) catch unreachable;

    lib.addCSourceFiles(.{
        .files = source_files.items,
        .flags = flags.items,
    });

    lib.linkLibC();
    lib.installHeader(b.path("zlib.h"), "zlib.h");

    b.installArtifact(lib);
}
