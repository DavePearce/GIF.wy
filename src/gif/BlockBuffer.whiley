package gif

import std::integer

public type Reader is {
    int index,  // index of current byte in data
    int end,    // current end of block
    int boff,    // bit offset in current byte
    byte[] data 
}

public function Reader(byte[] data, int start) -> Reader:
    int end = integer::toUnsignedInt(data[start])
    return {
        index: start+1,
        end: start+1+end,
        boff: 0,
        data: data
    }

public function read(Reader reader) -> (bool f, Reader r) :
    int boff = reader.boff
    // first, read the current bit
    byte b = reader.data[reader.index]
    b = b >> boff
    b = b & 0b00000001
    // now, move position to next bit
    boff = boff + 1
    if boff == 8:
        reader.boff = 0
        int index = reader.index + 1
        if index == reader.end:
            // need to roll over to next block
            int end = integer::toUnsignedInt(reader.data[index])
            index = index + 1
            reader.end = index + end
        reader.index = index
    else:
        reader.boff = boff
    // return the bit we've read
    return b == 0b00000001,reader

public function read(Reader reader, int nbits) -> (byte b, Reader rp)
requires nbits >= 0 && nbits < 8:
    byte mask = 0b00000001
    byte r = 0b
    int i = 0
    bool bit
    while i < nbits:
        bit,reader = read(reader)
        if bit:
            r = r | mask
        mask = mask << 1
        i = i + 1
    return r,reader

public function read_uint(Reader reader, int nbits) -> (int count, Reader rp):
    int base = 1
    int r = 0
    int i = 0
    bool bit
    //
    while i < nbits:
        bit,reader = read(reader)
        if bit:
            r = r + base
        base = base * 2
        i = i + 1
    return r,reader

public type Writer is {
    int index,  // index of current byte in data
    int boff,    // bit offset in current byte
    byte[] data 
}

public function Writer() -> Writer:
    return {
        index: 0,
        boff: 0,
        data: []
    }

public function write(Writer writer, bool bit) -> Writer:
    // first, check there's enough space
    int index = writer.index
    int boff = writer.boff
    if index >= |writer.data|:
        writer.data = resize(writer.data,|writer.data|*2,0b00000000)
    // second, write the bit out
    if bit:
        byte mask = 0b00000001 << boff
        writer.data[index] = writer.data[index] | mask
    // third, update offsets
    boff = boff + 1
    if boff == 8:
        writer.boff = 0
        writer.index = writer.index + 1
    else:
        writer.boff = boff
    // done!
    return writer

// ============================================================
// FIXME: this should be in the standard library!
// ============================================================

// Resize an array to a given size
public function resize(byte[] items, int size, byte element) -> (byte[] result)
// Required size cannot be negative
requires size >= 0
// Returned array is of specified size
ensures |result| == size
// If array is enlarged, the all elements up to new size match
ensures all { i in 0 .. |items| | i >= size || result[i] == items[i] }
// All new elements match given element
ensures all { i in |items| .. size | result[i] == element}:
    //
    byte[] nitems = [element; size]
    int i = 0
    while i < size && i < |items|
    where i >= 0 && |nitems| == size
    // All elements up to i match as before
    where all { j in 0..i | nitems[j] == items[j] }
    // All elements about size match element
    where all { j in |items| .. size | nitems[j] == element}:
        //
        nitems[i] = items[i]
        i = i + 1
    //
    return nitems
