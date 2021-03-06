import types
import utils
import bignum
import sugar
import strutils
import algorithm
import bitops

proc encode*(element: Element): string =
    ## Converts an element to it's byte array form
    var identifier = element.kind.ord()
    if element.encoding == Constructed:
        identifier.setBit(5)
    result = identifier.chr.`$`
    result &= element.getEncodedLength()
    result &= element.value

proc encode*(oid: Asn1ObjectIdentifier): string =
    var nums = collect(newSeq):
        for value in oid.split('.'):
            value.parseInt()
    nums = @[40 * nums[0] + nums[1]] & nums[2..^1]
    nums = nums.reversed()
    var tmpResult = newSeq[int]()
    for data in nums:
        tmpResult &= data and 0x7f
        var d = data
        while d > 0x7f:
            d = d shr 7
            tmpResult &= 0x80 or (d and 0x7f)
    tmpResult = tmpResult.reversed()
    for i in tmpResult:
        result &= chr(i)

proc add*(node: var Element, newNode: Element) =
    ## Adds a sequence to a sequence
    node.value &= newNode.encode()
    node.length += newNode.getTotalLength()

proc add*(node: var Element, newNode: Asn1ObjectIdentifier) =
    let value = newNode.encode()
    let newNode = newElement(ObjectIdentifier, value)
    node.add(newNode)

proc addNull*(node: var Element) =
    let newNode = newElement(Null, "")
    node.add(newNode)
    
proc add*(node: var Element, value: int8) =
    ## Adds an integer to a sequence    
    let newNode = newElement(Integer, $chr(value))
    node.add(newNode)
    
proc add*(node: var Element, value: Int) =
    var value = value
    var result = ""
    var index = 0
    if value > int.high:
        index = 1
        result = $chr(0) # Zero means that it is of arbitary precision
        
    while true:
        let number = (value and 0b11111111).toInt()
        if value == 0:
            break
        result.insert($number.chr(), index)
        value = value shr 8
    let newNode = newElement(Integer, result)
    node.add(newNode)
    
proc newSequence*(): Element =
    result = Element(kind: Sequence)
