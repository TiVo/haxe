/** *************************************************************************
 * Utf8String.hx
 *
 * Copyright 2015 TiVo, Inc.
 ************************************************************************** **/

/**
 * Utf8String is a wrapper class that wraps a String object that is encoded in
 * UTF-8 format and provides character based versions of the String
 * manipulation functions.  Utf8String is not a String proper, but can be
 * easily and efficiently turned into a String at the moment that the raw
 * bytes of the String are needed via the toString() function.
 *
 * For best and most efficient use of this class:
 * 1. Create a Utf8String instance wrapping any String object that could be
 *    manipulated, at the earliest possible time.
 * 2. Pass Utf8String objects around instead of converting a Utf8String to
 *    a String and then passing that along; because the converted String may
 *    need to be turned back into a Utf8String by whoever it is passed to, and
 *    that code may then need to pay the cost of computing the character count
 *    of the String again, when it was already known to the original
 *    Utf8String wrapper object.
 * 3. Extract the String object from a Utf8String object only at the moment
 *    when the String object needs to be displayed, printed, or written out to
 *    a Socket or File.
 **/
class Utf8String
{
    /**
     * Length, in characters, of the UTF-8 string
     **/
    public var length(get_length, null) : Int;

    /**
     * If the unicode character count is is known ahead of time, it is more
     * efficient to pass it in via the charCount parameter than to allow it to
     * be computed.  If it is not known, pass a value < 0 for charCount and it
     * will be computed when needed.
     **/
    public function new(s : String, charCount : Int = -1)
    {
        mString = s;
        mCharCount = charCount;
    }

    /**
     * Extracts the wrapped String and returns it.
     **/
    public function toString() : String
    {
        return mString;
    }

    /**
     * This function has the exact same semantics as String.charAt(), except
     * that the input index is a character index, not a byte index as it is
     * for String.
     **/
    public function charAt(index : Int) : Utf8String
    {
        if (mCharCount < 0) {
            this.computeCharLength();
        }

        // If the wrapped string has no multi-byte characters, it is pure 7
        // bit ASCII and String's normal byte oriented functions can be used
        if (mCharCount == mString.length) {
            var str = mString.charAt(index);
            return new Utf8String(str, str.length);
        }

        if ((index < 0) || (index >= mCharCount)) {
            return new Utf8String("", 0);
        }

        var byteIndex = this.CharIndexToByteIndex(index);

        return new Utf8String
            (mString.substr(byteIndex, 
                            Utf8CharByteCount(byteAt(byteIndex))), 1);
    }

    /**
     * This function has the exact same semantics as String.charCodeAt(),
     * except that the input index is a character index, not a byte index as
     * it is for String.
     **/
    public function charCodeAt(index : Int) : Null<Int>
    {
        if (mCharCount < 0) {
            this.computeCharLength();
        }

        // If the wrapped string has no multi-byte characters, it is pure 7
        // bit ASCII and String's normal byte oriented functions can be used
        if (mCharCount == mString.length) {
            return mString.charCodeAt(index);
        }

        if ((index < 0) || (index >= mCharCount)) {
            return null;
        }

        return this.DecodeUtf8(this.CharIndexToByteIndex(index));
    }

    /**
     * This function is to convert the lowercase characters in a String
     * to uppercase including diacritics in the ISO-8895-1 range.
     **/
    public function toUpperCase() : String
    {
        var len :Int = this.length; 
        var charCode :Int = 0;

        //a buffer to hold the result.
        var result_string = new haxe.Utf8();

        var index = 0;
        while (index < len) {
            charCode = this.charCodeAt(index++);
            
            if (charCode < 97) {
                result_string.addChar(charCode);
            }
            else if ((charCode <= 122) ||
                    ((charCode >= 224) && (charCode <= 255))) {
                result_string.addChar(charCode - 32);
            }   
            else {
                result_string.addChar(charCode);
            }
        }   
        
        return result_string.toString();
    }


    /** 
     * This function is to convert the uppercase characters in a String
     * to lowercase including diacritics in the ISO-8895-1 range.
     **/
    public function toLowerCase() : String
    {
        var len :Int = this.length;
        var charCode :Int = 0;

        //a buffer to hold the result.
        var result_string = new haxe.Utf8();

        var index = 0;
        while (index < len) {
            charCode = this.charCodeAt(index++);
            if (charCode < 65) {
                result_string.addChar(charCode);
            }
            else if ((charCode <= 90) ||
                    ((charCode >= 192) && (charCode <= 223))) {
                result_string.addChar(charCode + 32);
            }
            else {
                result_string.addChar(charCode);
            }
        }

        return result_string.toString();
    }

    /**
     * This function has the exact same semantics as String.indexOf(), except
     * that the input start index is a character index, not a byte index as it
     * is for String, and the returned index is a character index, not a byte
     * index as it is for String.
     **/
    public function indexOf(str : String, ?startIndex : Int) : Int
    {
        if (mCharCount < 0) {
            this.computeCharLength();
        }
        
        // If the wrapped string has no multi-byte characters, it is pure 7
        // bit ASCII and String's normal byte oriented functions can be used
        if (mCharCount == mString.length) {
            return mString.indexOf(str, startIndex);
        }

        if ((startIndex == null) || (startIndex < 0)) {
            startIndex = 0;
        }

        var byteIndex = mString.indexOf
            (str, this.CharIndexToByteIndex(startIndex));

        if (byteIndex < 0) {
            return -1;
        }

        return this.ByteIndexToCharIndex(byteIndex);
    }

    /**
     * This function has the exact same semantics as String.lastIndexOf(),
     * except that the input start index is a character index, not a byte
     * index as it is for String, and the returned index is a character index,
     * not a byte index as it is for String.
     **/
    public function lastIndexOf(str : String, ?startIndex : Int) : Int
    {
        if (mCharCount < 0) {
            this.computeCharLength();
        }
        
        // If the wrapped string has no multi-byte characters, it is pure 7
        // bit ASCII and String's normal byte oriented functions can be used
        if (mCharCount == mString.length) {
            return mString.lastIndexOf(str, startIndex);
        }

        if ((startIndex == null) || (startIndex >= mString.length)) {
            startIndex = mString.length - 1;
        }

        if (startIndex < 0) {
            return -1;
        }

        var byteIndex =
            mString.lastIndexOf(str, this.CharIndexToByteIndex(startIndex));

        if (byteIndex < 0) {
            return -1;
        }

        return this.ByteIndexToCharIndex(byteIndex);
    }

    /**
     * This function has the exact same semantics as String.substr(), except
     * that the input position is a character index, not a byte index as it is
     * for String, and the input length is a character length, not a byte
     * length as it is for String.
     **/
    public function substr(pos : Int, ?len : Int) : Utf8String
    {
        if (mCharCount < 0) {
            this.computeCharLength();
        }

        // If the wrapped string has no multi-byte characters, it is pure 7
        // bit ASCII and String's normal byte oriented functions can be used
        if (mCharCount == mString.length) {
            var str = mString.substr(pos, len);
            return new Utf8String(str, str.length);
        }

        if ((len != null) && (len <= 0)) {
            return new Utf8String("", 0);
        }

        if (pos >= 0) {
            if (pos >= mCharCount) {
                return new Utf8String("", 0);
            }
        }
        else {
            pos += mCharCount;
            if (pos < 0) {
                // This duplicates the logic of hxcpp String.cpp, not sure why
                // this is done rather than returning an empty string
                pos = 0;
            }
        }

        var bytePos = this.CharIndexToByteIndex(pos);

        if (len == null) {
            return new Utf8String(mString.substr(bytePos, null), -1);
        }

        if ((pos + len) > mCharCount) {
            len = mCharCount - pos;
        }

        var bp = bytePos;
        var left = len;

        while (left-- > 0) {
            bp += Utf8CharByteCount(byteAt(bp));
        }

        return new Utf8String(mString.substr(bytePos, bp - bytePos), len);
    }

    /**
     * This function has the exact same semantics as String.substring(),
     * except that the input start and end indices are character indices, not
     * byte indices as they are for String.
     **/
    public function substring(startIndex : Int, ?endIndex : Int) : Utf8String
    {
        if (mCharCount < 0) {
            this.computeCharLength();
        }

        // If the wrapped string has no multi-byte characters, it is pure 7
        // bit ASCII and String's normal byte oriented functions can be used
        if (mCharCount == mString.length) {
            var str = mString.substring(startIndex, endIndex);
            return new Utf8String(str, str.length);
        }

        if (startIndex < 0) {
            startIndex = 0;
        }

        if (endIndex < startIndex) {
            var tmp = startIndex;
            startIndex = endIndex;
            endIndex = tmp;
        }
        
        return this.substr(startIndex, endIndex - startIndex);
    }

    private function get_length() : Int
    {
        if (mCharCount < 0) {
            this.computeCharLength();
        }

        return mCharCount;
    }

    private function computeCharLength()
    {
        mCharCount = 0;
        #if js
        // Use standard string.length method for string length calculation
        // because string in JS is already presented in UTF-16 format and
        // string.length returns actual count of chars (not a bytes) that are
        // stored in string.
        mCharCount = mString.length;
        #else
        var pos : Int = 0;
        while (pos < mString.length) {
            var bc = Utf8CharByteCount(byteAt(pos));
            pos += bc;
            if (pos > mString.length) {
                // Invalid UTF-8: truncated last character
                return;
            }
            while (--bc > 0) {
                if ((byteAt(pos - bc) & 0x80) == 0) {
                    // Invalid UTF-8: malformed bytes
                    return;
                }
            }
            mCharCount += 1;
        }
        #end
    }

    /**
     * This helper function provides for the fastest possible byte indexing
     * into the wrapped String.
     **/
    private inline function byteAt(index : Int) : Int
    {
        return StringTools.fastCodeAt(mString, index);
    }

    private function CharIndexToByteIndex(charIndex : Int) : Int
    {
        var byteIndex = 0;

        while (charIndex-- > 0) {
            byteIndex += Utf8CharByteCount(byteAt(byteIndex));
        }

        return byteIndex;
    }

    private function ByteIndexToCharIndex(byteIndex : Int) : Int
    {
        var charIndex = 0;
        var bp = 0;

        while (bp < byteIndex) {
            bp += Utf8CharByteCount(byteAt(bp));
            charIndex += 1;
        }

        return charIndex;
    }

    private static function Utf8CharByteCount(first_char : Int) : Int
    {
        if (first_char < 0x80) {
            return 1;
        }

        if (first_char < 0xE0) {
            return 2;
        }
        
        if (first_char < 0xF0) {
            return 3;
        }
        
        if (first_char >= 0xFE) {
            // Invalid UTF-8
            return 1;
        }
        
        return 4;
    }

    private function DecodeUtf8(byteIndex : Int) : Int
    {
        var c = mString.charCodeAt(byteIndex);

        if (c < 0x80) {
            return c;
        }

        if (c < 0xE0) {
            var c2 = mString.charCodeAt(++byteIndex);
            var res = ((c & 0x1F) << 6) | (c2 & 0x3F);
            if (res <= 0x7F) {
                // UTF-8 encoding spec does not allow values that could have
                // been encoded in 1 byte to be encoded in 2 bytes
                return 0;
            }
            return res;
        }

        if (c < 0xF0) {
            var c2 = mString.charCodeAt(++byteIndex);
            var c3 = mString.charCodeAt(++byteIndex);
            var res = ((c & 0x0F) << 12) | ((c2 & 0x3F) << 6) | (c3 & 0x3F);
            if (res <= 0x7FF) {
                // UTF-8 encoding spec does not allow values that could have
                // been encoded in 1 or 2 bytes to be encoded in 3 bytes
                return 0;
            }
            return res;
        }

        if (c >= 0xFE) {
            // Invalid UTF-8: first byte >= 0xFE
            return 0;
        }

        var c2 = mString.charCodeAt(++byteIndex);
        var c3 = mString.charCodeAt(++byteIndex);
        var c4 = mString.charCodeAt(++byteIndex);

        var res = (((c & 0x07) << 18) | ((c2 & 0x3F) << 12) |
                   ((c3 & 0x3F) << 6) | (c4 & 0x3F));

        if (res <= 0xFFFF) {
            // UTF-8 encoding spec does not allow values that could have been
            // encoded in 1, 2, or 3 bytes to be encoded in 4 bytes
            return 0;
        }
    
        if (res > 0x10FFFF) {
            // Invalid UTF-8: > 0x10FFFF
            return 0;
        }

        return res;
    }

    /**
     * The wrapped String.
     **/
    private var mString : String;

    /**
     * If < 0, the character count of the string is not known, and will be
     * computed on demand.
     **/
    private var mCharCount : Int;
}
