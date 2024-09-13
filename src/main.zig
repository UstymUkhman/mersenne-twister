const std = @import("std");

const STATE_VECTOR_LENGTH = 624;
const STATE_VECTOR_M = 397;

const UPPER_MASK	     = 0x80000000;
const LOWER_MASK	     = 0x7fffffff;
const TEMPERING_MASK_B = 0x9d2c5680;
const TEMPERING_MASK_C = 0xefc60000;

const MTRand = struct
{
    mt: [STATE_VECTOR_LENGTH]u32,
    index: usize
};

// Sets initial seeds of MTRand.mt using the generator in input:
inline fn init_seeds(rand: *MTRand, seed: u32) void
{
    rand.index = 1;
    rand.mt[0] = seed & 0xffffffff;

    while (rand.index < STATE_VECTOR_LENGTH)
    {
        rand.mt[rand.index] = (rand.mt[rand.index - 1] *% 6069) & 0xffffffff;
        rand.index += 1;
    }
}

// Creates a new random number generator from a given seed:
fn create_generator(seed: u32) MTRand
{
    var rand: MTRand = undefined;
    init_seeds(&rand, seed);
    return rand;
}

// Returns a pseudo-randomly generated u32:
fn rand_u32(rand: *MTRand) u32
{
    var y: u32 = undefined;

    // const Static = struct {
    //     var mag: []u32 = .{ 0x0, 0x9908b0df };
    // };

    y = rand.mt[rand.index];
        rand.index += 1;

    y ^= (y >> 11);
    y ^= (y << 7) & TEMPERING_MASK_B;
    y ^= (y << 15) & TEMPERING_MASK_C;
    y ^= (y >> 18);
    
    return y;
}

// Returns a pseudo-randomly generated f64 in the range [0..1]:
pub fn rand_f64(rand: *MTRand) f64
{
    return @as(f64, @floatFromInt(rand_u32(rand))) / @as(f64, 0xffffffff);
}

// Command line entry point:
pub fn main() void
{
    _ = create_generator(1337);
    // var rand = create_generator(1337);
    // const random = rand_f64(&rand);

    // std.debug.print("{}\n", .{ random });
}
