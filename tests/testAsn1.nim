import unittest
import asn1m/[types, utils, encoder]
import bigints
include asn1m


suite "Reading tag Bytes":
    template testClass(input: int, checkClass: Classes): untyped =
        var element: Element
        discard input.readTag(element)
        check element.class == checkClass
                
    test "Reading tag kind":
        var element: Element
        discard 0b00000010.readTag(element)
        check element.kind == Integer

    test "Reading Universal class":
        # check 0b00000000.readTag().class == Universal
        testClass(0b00000010, Universal)
        # check 0b00000000.readTag().class == Universal

    test "Reading Application class":
        testClass(0b01000000, Application)
        
    test "Reading Context class":
        testClass(0b10000000, Context)
        
    test "Reading Private class":
        testClass(0b11000000, Private)
        
suite "Reading length":
    test "Short form":
        let input = chr(4) & chr(5)
        var index = 0
        check:
            input.readLength(index) == 4
            index == 1

    test "Long form":
        let input = chr(130) & chr(1) & chr(0x22)
        var index = 0
        check:
            input.readLength(index) == 290
            index == 3

type
    Person = object
        age: int

suite "Utils":
    test "Encoded length short form":
        let element = Element(kind: Integer, length: 5)
        check element.getEncodedLength == $chr(5)

    test "Encoded length long form":
        let element = Element(kind: Integer, length: 290)
        var index = 0
        check element.getEncodedLength().readLength(index) == 290

    test "BigInt or":
        let
            a = 0b1010.initBigInt()
            b = 0b0101.initBigInt()
        check (a or b) == 0b1111.initBigInt()

    test "BigInt and":
        let
            a = 0b0110.initBigInt()
            b = 0b1101.initBigInt()
        check (a and b) == 0b0100.initBigInt()

suite "Encoding":
    test "Sequence with an integer":
        var sequence = newSequence()
        sequence.add(9)
        check:
            sequence.length == 3

    test "Sequence in a sequence":
        var seq1 = newSequence()
        check seq1.length == 0
        seq1.add(11)
        var seq2 = newSequence()
        seq2.add(9)
        seq2.add(100)
        seq2.add(14)
        seq1.add(seq2)
        check:
            seq1.length == 14
            seq1.getTotalLength() == 16

    test "Sequence with Big Int":
        var sequence = newSequence()
        sequence.add(initBigInt(123456))
        check sequence.length == 6

suite "Decoding":
    test "Basic integer":
        let input = chr(2) & chr(1) & chr(69)
        var element: Element
        discard input.readElement(element)
        check element.value[0] == chr(69)

    test "Big integer":
        var sequence = newSequence()
        sequence.add(initBigInt(123456))
        var element: Element
        discard sequence.value.readElement(element)        
        check element.readInt() == initBigInt(123456)
