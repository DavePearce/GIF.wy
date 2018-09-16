package gif

public type Reader is {
    int index,  // index of current byte in data
    int end,    // current end of block
    int boff,    // bit offset in current byte
    byte[] data 
}

public function Reader(byte[] data, int start) -> Reader:
    end = Byte.toUnsignedInt(data[start])
    return {
        index: start+1,
        end: start+1+end,
        boff: 0,
        data: data
    }

public function read(Reader reader) -> (bool b, Reader r) :
    boff = reader.boff
    // first, read the current bit
    b = reader.data[reader.index]
    b = b >> boff
    b = b & 0b00000001
    // now, move position to next bit
    boff = boff + 1
    if boff == 8:
        reader.boff = 0
        index = reader.index + 1
        if index == reader.end:
            // need to roll over to next block
            end = Byte.toUnsignedInt(reader.data[index])
            index = index + 1
            reader.end = index + end
        reader.index = index
    else:
        reader.boff = boff
    // return the bit we've read
    return b == 0b00000001,reader

public function read(Reader reader, int nbits) -> (byte b, Reader r)
requires nbits >= 0 && nbits < 8:
    mask = 0b00000001
    r = 0b
    int i = 0
    while i < nbits:
        bit,reader = read(reader)
        if bit:
            r = r | mask
        mask = mask << 1
        i = i + 1
    return r,reader

public function readUnsignedInt(Reader reader, int nbits) -> (int count, Reader r):
    base = 1
    r = 0
    int i = 0
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
    index = writer.index
    boff = writer.boff
    if index >= |writer.data|:
        writer.data = writer.data + [0b00000000]
    // second, write the bit out
    if bit:
        mask = 0b00000001 << boff
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