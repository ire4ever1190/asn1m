import strutils
import strformat
import asn1m/[types, utils]
include asn1m/encoder
include asn1m/decoder


proc deco(input: string): string = 
    for chr in input:
        result &= $ord(chr) & " "
        
proc `$`*(input: Element): string =
    result &= "kind: " & $input.kind & "\n"
    result &= "length: " & $input.length & "\n"
    case input.kind:
        of Sequence:
            let children = input.readSequence()
            result &= &"children: {len(children)}\n\n"
            for value in children:
                result &= ($value).indent(2)
                result &= "\n"
        of Null:
            discard
        else:
            result &= "value: " & deco(input.value) & "\n"

