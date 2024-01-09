const std = @import("std");
const data = @import("./data.zig");
const ArrayList = std.ArrayList;

fn numberFromWord(str: []const u8) ?u8 {
    if (std.mem.containsAtLeast(u8, str, 1, "one")) {
        return '1';
    }
    if (std.mem.containsAtLeast(u8, str, 1, "two")) {
        return '2';
    }
    if (std.mem.containsAtLeast(u8, str, 1, "three")) {
        return '3';
    }
    if (std.mem.containsAtLeast(u8, str, 1, "four")) {
        return '4';
    }
    if (std.mem.containsAtLeast(u8, str, 1, "five")) {
        return '5';
    }
    if (std.mem.containsAtLeast(u8, str, 1, "six")) {
        return '6';
    }
    if (std.mem.containsAtLeast(u8, str, 1, "seven")) {
        return '7';
    }
    if (std.mem.containsAtLeast(u8, str, 1, "eight")) {
        return '8';
    }
    if (std.mem.containsAtLeast(u8, str, 1, "nine")) {
        return '9';
    }
    return null;
}

fn numbersFromStr(str: []const u8, numbers: *ArrayList(u32)) !void {
    var foundNumbers = ArrayList(u8).init(numbers.allocator);
    defer foundNumbers.deinit();

    var letters = ArrayList(u8).init(numbers.allocator);
    defer letters.deinit();
    for (str) |char| {
        const num: u8 = switch (char) {
            '1'...'9' => |digit| digit,
            'a'...'z', 'A'...'Z' => |letter| blk: {
                try letters.append(letter);
                const foundNumberFromWord = numberFromWord(letters.items);
                if (foundNumberFromWord) |foundNumber| {
                    const lastLetter: u8 = letters.getLast();
                    letters.clearAndFree();
                    try letters.append(lastLetter);
                    break :blk foundNumber;
                }
                continue;
            },
            else => continue,
        };
        try foundNumbers.append(num);
    }
    const firstAndLast = [2]u8{ foundNumbers.items[0], foundNumbers.items[foundNumbers.items.len - 1] };
    const parsedNum = try std.fmt.parseInt(u32, &firstAndLast, 10);
    try numbers.append(parsedNum);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const deinitStatus = gpa.deinit();
        if (deinitStatus == .leak) @panic("gpa leaked memory");
    }
    const allocator = gpa.allocator();

    const dataList = try data.loadData(allocator, "data/day1.txt");
    defer {
        for (dataList.items) |line| allocator.free(line);
        dataList.deinit();
    }

    var numbers = ArrayList(u32).init(allocator);
    defer numbers.deinit();
    for (dataList.items) |line| {
        try numbersFromStr(line, &numbers);
    }
    var sum: u32 = 0;
    for (numbers.items) |num| {
        sum += num;
    }
    std.debug.print("sum: {}\n", .{sum});
}
