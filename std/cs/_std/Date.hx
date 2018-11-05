/*
 * Copyright (C)2005-2017 Haxe Foundation
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
package;
import cs.system.DateTime;
import cs.system.TimeSpan;
import haxe.Int64;

#if core_api_serialize
@:meta(System.Serializable)
#end
@:coreApi class Date
{
	@:readOnly private static var epochTicks:Int64 = new DateTime(1970, 1, 1).Ticks;
	private var date:DateTime;

	public function new(year : Int, month : Int, day : Int, hour : Int = 0, min : Int = 0, sec : Int = 0, millisec : Int = 0) : Void
	{
		if (day <= 0) day = 1;
		if (year <= 0) year = 1;
		date = new DateTime(year, month + 1, day, hour, min, sec);
	}

	@:overload private function new(native:DateTime)
	{
		date = native;
	}

	public inline function getTime() : Float
	{
		return cast(cs.system.TimeZone.CurrentTimeZone.ToUniversalTime(date).Ticks - epochTicks, Float) / cast(TimeSpan.TicksPerMillisecond, Float);
	}

	public inline function getHours() : Int
	{
		return date.Hour;
	}

	public inline function getMinutes() : Int
	{
		return date.Minute;
	}

	public inline function getSeconds() : Int
	{
		return date.Second;
	}

    public inline function getMilliseconds() : Int { return 0; }

	public inline function getFullYear() : Int
	{
		return date.Year;
	}

	public inline function getMonth() : Int
	{
		return date.Month - 1;
	}

	public inline function getDate() : Int
	{
		return date.Day;
	}

	public inline function getDay() : Int
	{
		return cast(date.DayOfWeek, Int);
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
		var m = getUtcMonth() + 1;
		var d = getUtcDate();
		var h = getUtcHours();
		var mi = getUtcMinutes();
		var s = getUtcSeconds();
		return (getUtcFullYear())
			+"-"+(if( m < 10 ) "0"+m else ""+m)
			+"-"+(if( d < 10 ) "0"+d else ""+d)
			+" "+(if( h < 10 ) "0"+h else ""+h)
			+":"+(if( mi < 10 ) "0"+mi else ""+mi)
			+":"+(if( s < 10 ) "0"+s else ""+s);
    }

	public function toString():String
	{
		var m = getMonth() + 1;
		var d = getDate();
		var h = getHours();
		var mi = getMinutes();
		var s = getSeconds();
		return (getFullYear())
			+"-"+(if( m < 10 ) "0"+m else ""+m)
			+"-"+(if( d < 10 ) "0"+d else ""+d)
			+" "+(if( h < 10 ) "0"+h else ""+h)
			+":"+(if( mi < 10 ) "0"+mi else ""+mi)
			+":"+(if( s < 10 ) "0"+s else ""+s);
	}

	static public inline function now() : Date
	{
		return new Date(DateTime.Now);
	}

	static public inline function fromTime( t : Float ) : Date
	{
		return new Date(cs.system.TimeZone.CurrentTimeZone.ToLocalTime(new DateTime(cast(t * cast(TimeSpan.TicksPerMillisecond, Float), Int64) + epochTicks)));
	}

	public static function fromString( s : String, isUtc : Bool = false ) : Date
	{
		switch( s.length )
		{
			case 8: // hh:mm:ss
				var k = s.split(":");
				return isUtc ? Date.fromUTC(1, 1, 1, Std.parseInt(k[0]), Std.parseInt(k[1]), Std.parseInt(k[2])) :
                        new Date(1, 1, 1, Std.parseInt(k[0]), Std.parseInt(k[1]), Std.parseInt(k[2]));
			case 10: // YYYY-MM-DD
				var k = s.split("-");
				return isUtc ? Date.fromUTC(Std.parseInt(k[0]),Std.parseInt(k[1]) - 1,Std.parseInt(k[2]),0,0,0) :
                        new Date(Std.parseInt(k[0]),Std.parseInt(k[1]) - 1,Std.parseInt(k[2]),0,0,0);
			case 19: // YYYY-MM-DD hh:mm:ss
				var k = s.split(" ");
				var y = k[0].split("-");
				var t = k[1].split(":");
				return isUtc ? Date.fromUTC(Std.parseInt(y[0]),Std.parseInt(y[1]) - 1,Std.parseInt(y[2]),Std.parseInt(t[0]),Std.parseInt(t[1]),Std.parseInt(t[2])) :
                        new Date(Std.parseInt(y[0]),Std.parseInt(y[1]) - 1,Std.parseInt(y[2]),Std.parseInt(t[0]),Std.parseInt(t[1]),Std.parseInt(t[2]));
			default:
				throw "Invalid date format : " + s;
		}
	}

	private static inline function fromNative( d : cs.system.DateTime ) : Date
	{
		return new Date(d);
	}
}
