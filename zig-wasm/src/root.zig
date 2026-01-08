const std = @import("std");

export fn decrypt(data: [*]u8, data_len: usize, result: [*]u8) void {
    const keyspace = data[0];
    var key = data[1..33].*;
    const nonce = data[33..45].*;
    const ciphertext = data[45 .. data_len - 16];
    const tag: [16]u8 = @as(*[16]u8, @ptrCast(&data[data_len - 16])).*;
    const ad = "";

    const result_len = data_len - 45 - 16;

    while (true) {
        var i: u8 = 0;
        while (i < keyspace) : (i += 1) {
            const shift: u3 = @intCast(i & 7);
            key[i >> 3] ^= @as(u8, 1) << shift;
            if ((key[i >> 3] >> shift) & 1 != 0)
                break;
        }

        std.crypto.aead.aes_gcm.Aes256Gcm.decrypt(result[0..result_len], ciphertext, tag, ad, nonce, key) catch continue;
        break;
    }
}
