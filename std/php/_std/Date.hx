/*
 * Copyright (C)2005-2015 Haxe Foundation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */
@:coreApi @:final class Date
{
	private var __t : Float;

	public function new(year : Int, month : Int, day : Int, hour : Int = 0, min : Int = 0, sec : Int = 0, millisec : Int = 0) : Void {
		__t = untyped __call__("mktime", hour, min, sec, month+1, day, year);
	}

	public function getTime() : Float {
		return __t * 1000;
	}

	private function getPhpTime() : Float {
		return __t;
	}

	public function getFullYear() : Int {
		return untyped __call__("intval", __call__("date", "Y", this.__t));
	}

	public function getMonth() : Int {
		var m : Int = untyped __call__("intval", __call__("date", "n", this.__t));
		return -1 + m;
	}

	public function getDate() : Int {
		return untyped __call__("intval", __call__("date", "j", this.__t));
	}

	public function getHours() : Int {
		return untyped __call__("intval", __call__("date", "G", this.__t));
	}

	public function getMinutes() : Int {
		return untyped __call__("intval", __call__("date", "i", this.__t));
	}

	public function getSeconds() : Int {
		return untyped __call__("intval", __call__("date", "s", this.__t));
	}

    public function getMilliseconds() : Int { return 0; }

	public function getDay() : Int {
		return untyped __call__("intval", __call__("date", "w", this.__t));
	}

    public function timezoneOffset() : Int {
        // it is incorrect to fetch local timezone offset based on system settings
        // even for local timezone, based on date ... timezone offset varies
        // e.g. for a system that's currently in DST, offset may be -7 but, for a future date it could be -8
        //      so, reading system timezone offset and applying it to future date is incorrect

        return 0; // TODO: fix this
    }

    public function isDST() : Bool {
        // it is incorrect to fetch DST flag based on system settings
        // even for local timezone, based on date ... DST flag varies
        // e.g. a system could be currently in DST but a future Date object is not

        return false; // TODO: fix this
    }

    public function getUtcHours() : Int {
        return 0; // TODO: fix this
    }

    public function getUtcMinutes() : Int {
        return 0; // TODO: fix this
    }

    public function getUtcSeconds() : Int {
        return 0; // TODO: fix this
    }

    public function getUtcMilliseconds() : Int {
        return 0; // TODO: fix this
    }

    public function getUtcFullYear() : Int {
        return 0; // TODO: fix this
    }

    public function getUtcMonth() : Int {
        return 0; // TODO: fix this
    }

    public function getUtcDate() : Int {
        return 0; // TODO: fix this
    }

    public function getUtcDay() : Int {
        return 0; // TODO: fix this
    }

    public static function fromUTC( year : Int, month : Int, day : Int, hour : Int = 0, min : Int = 0, sec : Int = 0, millisec : Int = 0 ) : Date {
        var d : Date = new Date(year,month,day,hour,min,sec,millisec);
        return fromTime(((d.getTime()/1000) + d.timezoneOffset())*1000); // TODO: fix this
    }

    public function toUtcString():String {
        return toString(); // TODO: fix this
    }

	public function toString():String {
		return untyped __call__("date", "Y-m-d H:i:s", this.__t);
	}

	public static function now() : Date {
		return fromPhpTime(untyped __call__("round", __call__("microtime", true), 3));
	}

	static function fromPhpTime( t : Float ) : Date {
		var d = new Date(2000,1,1,0,0,0);
		d.__t = t;
		return d;
	}

	public static function fromTime( t : Float ) : Date {
		var d = new Date(2000,1,1,0,0,0);
		d.__t = t / 1000;
		return d;
	}

	public static function fromString( s : String, isUtc : Bool = false ) : Date {
		return fromPhpTime(untyped __call__("strtotime", s)); // TODO: fix this
	}
}


