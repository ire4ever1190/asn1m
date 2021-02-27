type
    asn1Kind* = enum
        Zero             = 0
        Boolean          = 1
        Integer          = 2
        BitString        = 3
        OctetString      = 4
        Null             = 5
        ObjectIdentifier = 6
        Enumerated       = 10
        UTF8String       = 12
        Sequence         = 16
        Set              = 17
        PrintableString  = 19
        IA5String        = 22
        UTCTime          = 23
        UnicodeString    = 30

    Encoding* = enum
        Primitive   = 0
        Constructed = 32

    Classes* = enum
        Universal   = 0
        Application = 64    
        Context     = 128
        Private     = 192

    Value* = object
        case kind*: asn1Kind
            of Sequence:
                children*: seq[Value]
            else:
               value*: string
        class*: Classes
        encoding*: Encoding
        length*: int
