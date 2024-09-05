const builtin = @import("builtin");
const std = @import("std");
const Path = std.Build.LazyPath;

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    var lib = b.addStaticLibrary(.{
        .name = "z",
        .target = target,
        .optimize = optimize,
    });

    var source_files = std.ArrayList([]const u8).init(b.allocator);
    defer source_files.deinit();
    var flags = std.ArrayList([]const u8).init(b.allocator);
    defer flags.deinit();

    const config_header = b.addConfigHeader(
        .{
            .style = .{ .cmake = b.path("zconf.h.cmakein") },
            .include_path = "zconf.h",
        },
        .{
            .HAVE_SYS_TYPES_H = true,
            .HAVE_STDINT_H = true,
            .HAVE_STDDEF_H = true,
            .HAVE_UNISTD_H = true,
            .Z_HAVE_UNISTD_H = true,
        },
    );
    lib.addConfigHeader(config_header);

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
        "inflate.c",
        "infback.c",
        "inftrees.c",
        "inffast.c",
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
    lib.installHeader(config_header.getOutput(), "zconf.h");

    b.installArtifact(lib);
}
