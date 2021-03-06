import unittest
import asn1m/[types, utils, encoder,  simple, decoder]
import bignum
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
        testClass(0b00000010, Universal)

    test "Reading Application class":
        testClass(0b01000000, Application)
        
    test "Reading Context class":
        testClass(0b10000000, Context)
        
    test "Reading Private class":
        testClass(0b11000000, Private)

    test "Reading Primitive tag":
        var element: Element
        discard 0b00000000.readTag(element)
        check element.encoding == Primitive
        discard 0b00100000.readTag(element)
        check element.encoding != Primitive
        
    test "Reading Constructed tag":
        var element: Element
        discard 0b00100000.readTag(element)
        check element.encoding == Constructed
        
        
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

suite "Encoding":
    test "Sequence with an integer":
        var sequence = newSequence()
        sequence.encoding = Constructed
        sequence.add(9)
        check:
            sequence.length == 3
        echo sequence.encode().deco()
        
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
        sequence.add(123456.newInt())
        check sequence.length == 5

    test "Sequence with Big Big int":
        var sequence = newSequence()
        var num = newInt(0)
        num.inc culong.high
        num.inc culong.high
        num.inc culong.high
        num.inc culong.high

        var num2 = newInt(65537)
        
        sequence.add(num)
        sequence.add(num2)
        var element: Element
        var start = sequence.value.readElement(element)
        check element.readInt() == num
        discard sequence.value.readElement(element, start = start)
        # echo sequence.value.deco()
        check element.readInt() == 65537.newInt()

    test "Sequence with Object identifier":
        var sequence = newSequence()
        sequence.add(Asn1ObjectIdentifier("1.2.840.113549.1.1.1"))
        # var element: Element
        # Basically tests reading OID as well which isn't good
        # discard sequence.value.readElement(element)
        # check element.readOID() == "1.2.840.113549.1.1.1"
        

suite "Decoding":
    test "Basic integer":
        let input = chr(2) & chr(1) & chr(69)
        var element: Element
        discard input.readElement(element)
        check element.value[0] == chr(69)

    test "Big integer":
        var sequence = newSequence()
        sequence.add(123456.newInt())
        var element: Element
        discard sequence.value.readElement(element)        
        check element.readInt() == 123456.newInt()

    test "Object Identifier":
        var element: Element
        discard """
        MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAM/0IWKSkgYnxCVIvnj9jW75HKq67auL
        PCf5k/5U/QYATtcswEAxtEI+KtEyM6ZsiZGy6a4fD9gleHT5DhpefKMCAwEAAQ==
        """.decode().readElement(element)
        discard element.value.readElement(element)
        discard element.value.readElement(element)
        check element.readOID() == "1.2.840.113549.1.1.1"

suite "Simple api":
    let stream = newAsn1Reader("""
            MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAM/0IWKSkgYnxCVIvnj9jW75HKq67auL
            PCf5k/5U/QYATtcswEAxtEI+KtEyM6ZsiZGy6a4fD9gleHT5DhpefKMCAwEAAQ==
            """.decode())

    setup:
        stream.seek(0)

    test "Read sequence":
        discard stream.readSeq()

    test "Read object identifier":
        let currentSeq = stream.readSeq().readSeq()
        check currentSeq.readOID() == "1.2.840.113549.1.1.1" 

    test "Reading null":
        let currentSeq = stream.readSeq().readSeq()
        discard currentSeq.readOID()
        currentSeq.readNull()

