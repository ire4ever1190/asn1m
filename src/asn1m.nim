import base64
import strutils
import bitops
import strformat
import asn1m/[types, utils]
import sugar

proc deco(input: string): string = 
    for chr in input:
        result &= $ord(chr) & " "
        
proc `$`(input: Value): string =
    result &= "kind: " & $input.kind & "\n"
    result &= "length: " & $input.length & "\n"
    case input.kind:
        of Sequence:
            result &= &"children: {len(input.children)}\n"
            for value in input.children:
                result &= ($value).indent(2)
                result &= "\n"
        of Null:
            discard
        else:
            result &= "value: " & deco(input.value)

proc readLength(input: string, index: var int): int =
    result = input[index].ord
    # If the 8th bit is one then the length is in long form
    if result.testBit(7):
        var lengthLen = result.masked(0b01111111)
        result = 0
        for i in 0 ..< lengthLen:
            inc index
            # Concat the binary numbers together
            result = (result shl 8) or input[index].ord
    inc index
    
proc readTag*(tagByte: int): Value =
    result = Value(
            kind: asn1Kind(tagByte.masked(0b00011111))
    )
    #
    # Bits 7 and 8 define the class
    #
    if tagByte.testBit(7) and tagByte.testBit(6):
        result.class = Private
    elif tagByte.testBit(7) and not tagByte.testBit(6):
        result.class = Context
    elif not tagByte.testBit(7) and tagByte.testBit(6):
        result.class = Application
    else:
        result.class = Universal

proc readValue(input: string, start: int = 0): tuple[value: Value, newStart: int] =
    ## Reads an encoded value
    ## start is the index of the asn1 tag
    # deco(input)
    if start >= input.len(): return
    var index = start
    let tagByte = input[index].ord
    result.value = tagByte.readTag()
    
    inc index
    result.value.length = input.readLength(index)
    # echo "after length val ", input[index].ord
    case result.value.kind:
        of Sequence:
            var dataRead = 0
            while dataRead < result.value.length:
                let (child, newIndex) = readValue(input, index)
                index = newIndex 
                result.value.children &= child
                dataRead += child.getTotalLength() # Length of a sequence includes the metadata of data
            echo dataRead
        else:
            for i in 0 ..< result.value.length:
                result.value.value &= input[index]
                inc index
    result.newStart = index
        
macro asn1(input: typed): untyped =
    discard
