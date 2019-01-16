package gif

import u8 from std::integer
import u16 from std::integer
import string from std::ascii

import Image
import RGBA

// A colour in a GIF file is an unsigned integer between 0..255.
public type Colour is {
    u8 red,
    u8 green,
    u8 blue
}

public function Colour(int red, int green, int blue) -> Colour:
    return {
        red: red, 
        green: green,
        blue: blue
    }

// Colour maps are an optional assignment of colour indices to rgb
// values.
type ColourMap is Colour[]|null

// Defines standard magic numbersx
final string GIF87a_MAGIC = "GIF87a"
final string GIF89a_MAGIC = "GIF89a"

// A GIF file
public type GIF is {
    string magic,
    u16 width,  // screen width
    u16 height, // screen height
    u8 background, // index of background colour
    ColourMap colourMap,
    ImageDescriptor[] images,
    Extension[] extensions
}

// Construct a GIF file with the given attributes
public function GIF(string magic, u16 width, u16 height,
    u8 background, ColourMap colourMap, ImageDescriptor[] images,
    Extension[] extensions) -> GIF:
    //
    return {
        magic: magic,
        width: width,
        height: height,
        background: background,
        colourMap: colourMap,
        images: images,
        extensions: extensions
    }

// Decode a GIF file from a give list of bytes

/*
public function decode(byte[] bytes) -> GIF:
    return Decoder.decode(bytes)
*/

// An image descriptor within a GIF file
public type ImageDescriptor is {
    u16 left,
    u16 top,
    u16 width,
    u16 height,
    bool interlaced,
    ColourMap colourMap,
    int[] data
}

// Construct a GIF image with the given attributes.
public function ImageDescriptor(u16 left, u16 top, u16 width, u16 height,
        bool interlaced, ColourMap colourMap, int[] data) -> ImageDescriptor:
    return {
        left: left,
        top: top,
        width: width,
        height: height,
        interlaced: interlaced,
        colourMap: colourMap,
        data: data
    }

public type Extension is {
    int code,
    byte[] data
}

/*
public function toImage(GIF gif, ImageDescriptor img) -> Image:
    colourMap = img.colourMap
    if colourMap == null:
        colourMap = gif.colourMap
    if colourMap == null:
        throw {msg: "BROKEN"}
    data = []
    for index in img.data:
        col = colourMap[index]
        red = ((real)col.red) / 255
        green = ((real)col.green) / 255
        blue = ((real)col.blue) / 255
        data = data + [RGBA(red,green,blue,1.0)]
    return {
        width: img.width,
        height: img.height,
        data: data
    }
*/