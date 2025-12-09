const std = @import("std");
const day9 = @import("day9");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const argv = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, argv);

    if (argv.len > 2 and std.mem.eql(u8, argv[2], "2")) {
        const inputFile = argv[1];
        const file = try std.fs.cwd().openFile(inputFile, .{});
        defer file.close();

        var file_buffer: [4096]u8 = undefined;
        var reader = file.reader(&file_buffer);
        var points: std.ArrayList(day9.Point) = .empty;
        defer points.deinit(allocator);
        while (try reader.interface.takeDelimiter('\n')) |line| {
            if (std.mem.count(u8, line, ",") > 0) {
                var vals = std.mem.splitSequence(u8, line, ",");
                const xString = vals.next() orelse {
                    continue;
                };
                const yString = vals.next() orelse {
                    continue;
                };
                const x = try std.fmt.parseInt(i64, xString, 0);
                const y = try std.fmt.parseInt(i64, yString, 0);
                const newPoint = day9.Point.new(x, y);
                try points.append(allocator, newPoint);
            }
        }

        var polygon = try day9.Polygon.new(points, allocator);
        defer polygon.deinit(allocator);

        const largestRect = day9.getLargestRectanglePart2(polygon, points);
        std.debug.print("Largest rectangle is {}\n", .{largestRect});
    } else if (argv.len > 1) {
        const inputFile = argv[1];
        const file = try std.fs.cwd().openFile(inputFile, .{});
        defer file.close();

        var file_buffer: [4096]u8 = undefined;
        var reader = file.reader(&file_buffer);
        var points: std.ArrayList(day9.Point) = .empty;
        defer points.deinit(allocator);
        while (try reader.interface.takeDelimiter('\n')) |line| {
            if (std.mem.count(u8, line, ",") > 0) {
                var vals = std.mem.splitSequence(u8, line, ",");
                const xString = vals.next() orelse {
                    continue;
                };
                const yString = vals.next() orelse {
                    continue;
                };
                const x = try std.fmt.parseInt(i64, xString, 0);
                const y = try std.fmt.parseInt(i64, yString, 0);
                const newPoint = day9.Point.new(x, y);
                try points.append(allocator, newPoint);
            }
        }

        const largestRect = day9.getLargestRectangle(points);
        std.debug.print("Largest rectangle is {}\n", .{largestRect});
    } else {
        std.debug.print("Pass through the input file name", .{});
    }
}
