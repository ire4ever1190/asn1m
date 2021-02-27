import types
import bitops

proc getEncodedLength*(value: Value): string =
    ## Returns the length of the value in encoded form
    if value.length < 128:
        return $chr(value.length)
    else:
        var ints = newSeq[int8]()
        var lenlen = 0 # The length of the extra length octals
        var len = value.length
        # Split the length into chunks which each chunk being a byte
        while (len > 255): 
            ints.insert len.masked(0b11111111).int8
            len = len shr 8
        ints.insert len.masked(0b11111111).int8
        result = $chr(0x80 + len(ints))
        for byte in ints:
            result &= chr(byte)

proc getTotalLength*(value: Value): int =
    ## Gets the total length of a value
    if value.length < 128:
        # If it is less than 128 then short form for length declaration can be used
        # 1 byte tag + 1 byte length + length of value
        result = 1 + 1
        if value.kind == Sequence:
            for child in value.children:
                result += child.getTotalLength()
        else:
            result += value.length
    else:
        result = 1 + value.getEncodedLength().len() + value.length
