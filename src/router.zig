const std = @import("std");
const RadixTree = @import("radix.zig").RadixTree;
const Request = @import("request.zig").Request;
const Response = @import("response.zig").Response;
const HandlerFn = @import("server.zig").RequestHandler;

/// Contains a path and a handler function that
pub const Route = struct {
    /// Path by which the route is triggered
    path: []const u8,
    /// The handler function that will be called when triggered
    handler: HandlerFn,
};

/// Generic function that inserts each route's path into a radix tree
/// to retrieve the right route when a request has been made
pub fn router(comptime routes: []const Route) HandlerFn {
    comptime var radix = RadixTree(Route){};
    inline for (routes) |r| {
        _ = radix.insert(r.path, r);
    }
    return struct {
        fn serve(response: *Response, request: Request) callconv(.Async) !void {
            if (radix.getLongestPrefix(request.url.path)) |route|
                return route.handler(response, request)
            else
                return notFound(response, request);
        }
    }.serve;
}

/// Returns a 404 message
fn notFound(response: *Response, request: Request) !void {
    try response.notFound();
}

comptime {
    std.meta.refAllDecls(@This());
}
