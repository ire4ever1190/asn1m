import types
import utils
import bigints

proc add*(node: var Element, value: int8) =
    ## Adds an integer to a sequence    
    let newNode = newElement(Integer, $chr(value))
    node.value &= newNode.encode()
    # echo node.length
    node.length += newNode.getTotalLength()
    # echo newNode.getTotalLength()

proc add*(node: var Element, value: BigInt) =
    var value = value
    var result = $chr(0) # Zero means that it is of arbitary precision
    while true:
        let number = (value and 0b11111111.initBigInt()).limbs[0]
        if number == 0:
            break
        result.insert($number.chr(), 1)
        value = value shr 8
            
    let newNode = newElement(Integer, result)
    node.value &= newNode.encode()
    node.length += newNode.getTotalLength()
    
proc add*(node: var Element, newNode: Element) =
    ## Adds a sequence to a sequence
    node.value &= newNode.encode()
    node.length += newNode.getTotalLength()

proc newSequence*(): Element =
    result = Element(kind: Sequence)
