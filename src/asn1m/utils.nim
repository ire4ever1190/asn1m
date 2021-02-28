import types
import bitops
import bigints

proc `or`*(a, b: BigInt): BigInt =
    ## Implements bitwise or for big int in the most scuffed way
    var
        biggest  = ""
        smallest = ""
    if a > b:
        biggest = a.toString(base = 2)
        smallest = b.toString(base = 2)
    else:
        biggest = b.toString(base = 2)
        smallest = a.toString(base = 2)
    for i in 1..len(smallest):
        if smallest[^i] == '1' or biggest[^i] == '1':
            biggest[^i] = '1'
    result = initBigInt(biggest, base = 2)

proc `and`*(a, b: BigInt): BigInt =
    ## Implements bitwise and for big int in the most scuffed way
    var
        biggest  = ""
        smallest = ""
    if a > b:
        biggest = a.toString(base = 2)
        smallest = b.toString(base = 2)
    else:
        biggest = b.toString(base = 2)
        smallest = a.toString(base = 2)
    for i in 1..len(smallest):
        if not (smallest[^i] == '1' and biggest[^i] == '1'):
            smallest[^i] = '0'
    result = initBigInt(smallest, base = 2)


proc getEncodedLength*(value: Element): string =
    ## Returns the length of the value in encoded form
    if value.length < 128:
        return $chr(value.length)
    else:
        var ints = newSeq[uint8]()
        var lenlen = 0 # The length of the extra length octals
        var len = value.length
        # Split the length into chunks which each chunk being a byte
        while (len > 255): 
            ints.insert len.masked(0b11111111).uint8
            len = len shr 8
        ints.insert len.masked(0b11111111).uint8
        result = $chr(0x80 + len(ints))
        for byte in ints:
            result &= chr(byte)

proc getTotalLength*(value: Element): int =
    ## Gets the total length of a value
    if value.length < 128:
        # If it is less than 128 then short form for length declaration can be used
        # 1 byte tag + 1 byte length + length of value
        result = 1 + 1 + value.length
    else:
        result = 1 + value.getEncodedLength().len() + value.length

proc encode*(element: Element): string =
    ## Converts an element to it's byte array form
    result = element.kind.ord().chr().`$`
    result &= element.getEncodedLength()
    result &= element.value
