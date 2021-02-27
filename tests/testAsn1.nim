import unittest
import asn1m/[types, utils, encoder]
import base64

include asn1m


suite "Reading tag Bytes":
    test "Reading tag kind":
        check 0b00000010.readTag().kind == Integer

    test "Reading Universal class":
        check 0b00000000.readTag().class == Universal

    test "Reading Application class":
        check 0b01000000.readTag().class == Application

    test "Reading Context class":
        check 0b10000000.readTag().class == Context

    test "Reading Private class":
        check 0b11000000.readTag().class == Private

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
        let value = Value(kind: Integer, length: 5)
        check value.getEncodedLength == $chr(5)

    test "Encoded length long form":
        let value = Value(kind: Integer, length: 290)
        var index = 0
        check value.getEncodedLength().readLength(index) == 290

suite "Encoding":
    test "Sequence with an integer":
        var sequence = newSequence()
        sequence.add(9)
        check:
            sequence.children.len == 1
            sequence.length       == 5

    test "Sequence in a sequence":
        var seq1 = newSequence()
        seq1.add(11)
        var seq2 = newSequence()
        seq2.add(9)
        seq2.add(100)
        seq2.add(14)
        seq1.add(seq2)
        check:
            seq1.children.len == 2
            seq2.children.len == 3
            seq1.length       == 16
        
suite "Decoding":
    test "Basic integer":
        let input = chr(2) & chr(1) & chr(69)
        let output = input.readValue()
        check output.value.value[0] == chr(69)

    test "Real world example":
        # decode a PEM public certificate
        let data = """MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA9S1c0E3lKIqTiX+ewDED
        7Nq4V/1DYaFNJbxL1BxfFCiMKz+K1+u2GlAewQ3+0f48MkmawDHqR+zkSwTkn9wB
        4zHCZUEYwwHL+288WmeUFMbp9HxPNgIPnx2yirvHrrYTgTD7/QnDAIVOFg7sJyv9
        0MKMvb+ke+Rvmacp8SHyJRbMGBvYd9V891qEmYApv921mRC0SBbmNxPxAcuv3W7O
        kYEr4wtmCBVRn7U/N+fO0KXcJSklS9tsKfJHD8/jvfCAYYeBPPOPb2e2QsfOyWjv
        GUQPtXDbyZXAF521PsQ9i03RSgqSBtRj+U2sNjpm/wsNV/bzt/XVoPhYW115xiDg
        JQIDAQAB""".decode()
        echo data.deco()
        echo data.readValue()
