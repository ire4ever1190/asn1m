import strutils
import strformat
import asn1m/[types, utils]
include asn1m/encoder
include asn1m/decoder
import base64

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

var element: Element
discard """
MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAM/0IWKSkgYnxCVIvnj9jW75HKq67auL
PCf5k/5U/QYATtcswEAxtEI+KtEyM6ZsiZGy6a4fD9gleHT5DhpefKMCAwEAAQ==
""".decode().readElement(element)
echo element
