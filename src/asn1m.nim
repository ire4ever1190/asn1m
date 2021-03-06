import strutils
import strformat
import asn1m/[types, utils]
import asn1m/decoder
import base64
        
proc `$`*(input: Element): string =
    result &= "kind: " & $input.kind & "\n"
    result &= "length: " & $input.length & "\n"
    result &= "class: " & $input.class & "\n"
    result &= "encoding: " & $input.encoding & "\n"
    case input.kind:
        of Sequence:
            let children = input.readSequence()
            result &= &"children: {len(children)}\n\n"
            for value in children:
                result &= ($value).indent(2)
                result &= "\n"
        of ObjectIdentifier:
            result &= "value: " & input.readOID() & "\n"
        of Null:
            discard
        else:
            result &= "value: " & deco(input.value) & "\n"
