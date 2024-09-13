const std = @import("std");

const STATE_VECTOR_L = 624;
const STATE_VECTOR_M = 397;

const UPPER_MASK = 0x80000000;
const LOWER_MASK = 0x7fffffff;

const MAX_U32 = std.math.maxInt(u32);

// Holds generated seeds and current index:
const MTRand = struct
{
    mt: [STATE_VECTOR_L]u32,
    index: usize
};

// Sets initial seeds of MTRand.mt using the generator in input:
inline fn init_seeds(rand: *MTRand, seed: u32) void
{
    rand.index = 1;
    rand.mt[0] = seed & 0xffffffff;

    while (rand.index < STATE_VECTOR_L)
    {
        rand.mt[rand.index] = (rand.mt[rand.index - 1] *% 6069) & 0xffffffff;
        rand.index += 1;
    }
}

// Returns a pseudo-randomly generated u32:
fn rand_u32(rand: *MTRand) u32
{
    var y: u32 = undefined;

    const Static = struct
    {
        var mag: [2]u32 = .{ 0x0, 0x9908b0df };
    };

    if (rand.index < 0 or rand.index >= STATE_VECTOR_L)
    {
        var kk: u32 = 0;

        const L_1 = STATE_VECTOR_L - 1;
        const L_M = STATE_VECTOR_L - STATE_VECTOR_M;
        const M_L = STATE_VECTOR_M - STATE_VECTOR_L;

        if (rand.index < 0 or rand.index >= STATE_VECTOR_L + 1)
            init_seeds(rand, 4357);

        while (kk < L_M)
        {
            y = (rand.mt[kk] & UPPER_MASK) | (rand.mt[kk + 1] & LOWER_MASK);
            rand.mt[kk] = rand.mt[kk + STATE_VECTOR_M] ^ (y >> 1) ^ Static.mag[y & 0x1];

            kk += 1;
        }

        while (kk < L_1)
        {
            const ml: u32 = @bitCast(@as(i32, M_L));
            y = (rand.mt[kk] & UPPER_MASK) | (rand.mt[kk + 1] & LOWER_MASK);
            rand.mt[kk] = rand.mt[kk +% ml] ^ (y >> 1) ^ Static.mag[y & 0x1];

            kk += 1;
        }

        y = (rand.mt[L_1] & UPPER_MASK) | (rand.mt[0] & LOWER_MASK);

        rand.mt[L_1] =
            rand.mt[STATE_VECTOR_M - 1] ^ (y >> 1) ^ Static.mag[y & 0x1];

        rand.index = 0;
    }

    y = rand.mt[rand.index];
        rand.index += 1;

    y ^= (y >> 11);
    y ^= (y <<  7) & 0x9d2c5680;
    y ^= (y << 15) & 0xefc60000;
    y ^= (y >> 18);

    return y;
}

// Creates a new random number generator from a given seed:
pub fn init(seed: ?u32) MTRand
{
    var rand: MTRand = undefined;
    const s = seed orelse 1337;

    init_seeds(&rand, s);
    return rand;
}

// Returns a pseudo-randomly generated f64 (in range 0 - 1):
pub fn random() f64
{
    return @as(f64, @floatFromInt(rand_u32(&generator))) / MAX_U32;
}

// Returns a pseudo-randomly generated i64 (in range min - max):
pub fn randomInt(min: i64, max: i64) i64
{
    const range: f64 = @floatFromInt(max - min + 1);
    const rand: i64 = @intFromFloat(random() * range);

    return min + rand;
}

// Returns a pseudo-randomly generated f64 (in range min - max):
pub fn randomFloat(min: f64, max: f64) f64
{
    return random() * (max - min) + min;
}

// First time initialization of the MTRand generator:
var generator = init(null);
