import types
import utils

proc add*(node: var Value, value: int8) =
    ## Adds an integer to a sequence
    let newNode = Value(
                kind: Integer,
                value: $chr(value),
                length: 1
            )
    node.children &= newNode
    node.length += newNode.getTotalLength()

proc add*(node: var Value, value: Value) =
    ## Adds a sequence to a sequence
    node.children &= value
    node.length += value.getTotalLength()

proc newSequence*(): Value =
    result = Value(kind: Sequence)
    result.length = result.getTotalLength()
