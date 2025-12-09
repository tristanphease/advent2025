const std = @import("std");

pub const Point = struct {
    x: i64,
    y: i64,

    pub fn new(x: i64, y: i64) Point {
        return Point{ .x = x, .y = y };
    }

    pub fn rectSize(self: Point, other: Point) u64 {
        return (@abs(self.x - other.x) + 1) * (@abs(self.y - other.y) + 1);
    }
};

const Line = struct {
    point1: Point,
    point2: Point,
};

pub const Polygon = struct {
    lines: std.ArrayList(Line),
    minX: i64,

    pub fn new(points: std.ArrayList(Point), allocator: std.mem.Allocator) !Polygon {
        var lines: std.ArrayList(Line) = .empty;
        var minX: i64 = std.math.maxInt(i64);
        for (0..points.items.len) |i| {
            const j = if (i == points.items.len - 1) 0 else i + 1;
            const newLine = Line{ .point1 = points.items[i], .point2 = points.items[j] };
            try lines.append(allocator, newLine);

            if (points.items[i].x < minX) minX = points.items[i].x;
        }
        return Polygon{ .lines = lines, .minX = minX };
    }

    pub fn deinit(self: *Polygon, allocator: std.mem.Allocator) void {
        self.lines.deinit(allocator);
        self.* = undefined;
    }

    // doing this: https://en.wikipedia.org/wiki/Point_in_polygon#Ray_casting_algorithm
    pub fn pointInPolygon(polygon: Polygon, point: Point) bool {
        var count: i32 = 0;
        for (polygon.lines.items) |line| {
            // we want to count the following:
            // - vertical line to the left of or including the point
            // - horizontal line to the left of the point
            if (line.point1.y == point.y and line.point2.y == point.y and
                (((line.point1.x <= point.x and line.point2.x <= point.x))))
            {
                count += 1;
            } else if (line.point1.y != line.point2.y and line.point1.x <= point.x) {
                const minY = @min(line.point1.y, line.point2.y);
                const maxY = @max(line.point1.y, line.point2.y);

                if (minY <= point.y and maxY >= point.y) {
                    count += 1;
                }
            }
        }
        return @rem(count, 2) == 1;
    }

    pub fn rectInPolygon(polygon: Polygon, point1: Point, point2: Point) bool {
        const minX = std.math.cast(usize, @min(point1.x, point2.x)).?;
        const maxX = std.math.cast(usize, @max(point1.x, point2.x)).?;
        const minY = std.math.cast(usize, @min(point1.y, point2.y)).?;
        const maxY = std.math.cast(usize, @max(point1.y, point2.y)).?;

        const point3 = Point.new(point1.x, point2.y);
        const point4 = Point.new(point2.x, point1.y);

        // check corners first since they're most likely to fail
        if (!pointInPolygon(polygon, point1)) {
            return false;
        }
        if (!pointInPolygon(polygon, point2)) {
            return false;
        }
        if (!pointInPolygon(polygon, point3)) {
            return false;
        }
        if (!pointInPolygon(polygon, point4)) {
            return false;
        }

        for (minY..maxY + 1) |y| {
            const newY = std.math.cast(i64, y).?;
            if (!pointInPolygon(polygon, Point.new(point1.x, newY))) {
                return false;
            }
            if (!pointInPolygon(polygon, Point.new(point2.x, newY))) {
                return false;
            }
        }

        for (minX..maxX + 1) |x| {
            const newX = std.math.cast(i64, x).?;
            if (!pointInPolygon(polygon, Point.new(newX, point1.y))) {
                return false;
            }
            if (!pointInPolygon(polygon, Point.new(newX, point2.y))) {
                return false;
            }
        }
        return true;
    }
};

pub fn getLargestRectangle(points: std.ArrayList(Point)) u64 {
    var largestRect: u64 = 0;
    for (0..points.items.len) |i| {
        for (i + 1..points.items.len) |j| {
            const rectSize = points.items[i].rectSize(points.items[j]);
            if (rectSize > largestRect) {
                largestRect = rectSize;
            }
        }
    }
    return largestRect;
}

pub fn getLargestRectanglePart2(polygon: Polygon, points: std.ArrayList(Point)) u64 {
    var largestRect: u64 = 0;
    for (0..points.items.len) |i| {
        for (i + 1..points.items.len) |j| {
            const point1 = points.items[i];
            const point2 = points.items[j];
            const rectSize = point1.rectSize(point2);
            if (rectSize > largestRect and polygon.rectInPolygon(point1, point2)) {
                std.debug.print("size: {d}, point1: [x: {d}, y: {d}], point2: [x: {d}, y : {d}]\n", .{ rectSize, point1.x, point1.y, point2.x, point2.y });
                largestRect = rectSize;
            }
        }
    }
    return largestRect;
}

test "largest rect" {
    const gpa = std.testing.allocator;
    var pointList: std.ArrayList(Point) = .empty;
    defer pointList.deinit(gpa);
    try pointList.append(gpa, Point.new(7, 1));
    try pointList.append(gpa, Point.new(11, 1));
    try pointList.append(gpa, Point.new(11, 7));
    try pointList.append(gpa, Point.new(9, 7));
    try pointList.append(gpa, Point.new(9, 5));
    try pointList.append(gpa, Point.new(2, 5));
    try pointList.append(gpa, Point.new(2, 3));
    try pointList.append(gpa, Point.new(7, 3));

    try std.testing.expectEqual(50, getLargestRectangle(pointList));
}

test "largest rect part 2" {
    const gpa = std.testing.allocator;
    var pointList: std.ArrayList(Point) = .empty;

    defer pointList.deinit(gpa);
    try pointList.append(gpa, Point.new(7, 1));
    try pointList.append(gpa, Point.new(11, 1));
    try pointList.append(gpa, Point.new(11, 7));
    try pointList.append(gpa, Point.new(9, 7));
    try pointList.append(gpa, Point.new(9, 5));
    try pointList.append(gpa, Point.new(2, 5));
    try pointList.append(gpa, Point.new(2, 3));
    try pointList.append(gpa, Point.new(7, 3));
    var polygon = try Polygon.new(pointList, gpa);
    defer polygon.deinit(gpa);

    try std.testing.expectEqual(24, getLargestRectanglePart2(polygon, pointList));
}
