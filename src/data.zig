const std = @import("std");
const ArrayList = std.ArrayList;

pub fn loadData(allocator: std.mem.Allocator, path: []const u8) !ArrayList([]const u8) {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    var bufReader = std.io.bufferedReader(file.reader());
    var inStream = bufReader.reader();

    var values = ArrayList([]const u8).init(allocator);
    while (try inStream.readUntilDelimiterOrEofAlloc(
        allocator,
        '\n',
        std.math.maxInt(u32),
    )) |line| {
        try values.append(line);
    }
    return values;
}

test "can open day one file" {
    const allocator = std.testing.allocator;
    var expectedList = ArrayList([]const u8).init(allocator);
    defer expectedList.deinit();
    try expectedList.append("1abc2");
    try expectedList.append("pqr3stu8vwx");
    try expectedList.append("a1b2c3d4e5f");
    try expectedList.append("treb7uchet");

    const result = try loadData(allocator, "./data/day1.test.txt");
    defer result.deinit();
    try std.testing.expectEqualDeep(expectedList.items, result.items);
    for (result.items) |line| allocator.free(line);
}
