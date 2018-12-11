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
@:coreApi class Date {

	private var mSeconds:Float;

	public function new(year : Int, month : Int, day : Int, hour : Int = 0, min : Int = 0, sec : Int = 0, millisec : Int = 0) : Void {
		basicCheck( year, month, day, hour, min, sec, millisec);
		mSeconds = untyped __global__.__hxcpp_new_date(year, month, day, hour, min, sec, millisec);
	}

	public function getTime() : Float {
		return mSeconds * 1000.0;
	}

	public function getHours() : Int { return untyped __global__.__hxcpp_get_hours(mSeconds); }

	public function getMinutes() : Int { return untyped __global__.__hxcpp_get_minutes(mSeconds); }

	public function getSeconds() : Int { return untyped __global__.__hxcpp_get_seconds(mSeconds); }

	public function getMilliseconds() : Int { return Std.int(getTime()%1000); }

	public function getFullYear() : Int { return untyped __global__.__hxcpp_get_year(mSeconds); }

	public function getMonth() : Int { return untyped __global__.__hxcpp_get_month(mSeconds); }

	public function getDate() : Int { return untyped __global__.__hxcpp_get_date(mSeconds); }

	public function getDay() : Int { return untyped __global__.__hxcpp_get_day(mSeconds); }

	public function getUtcHours() : Int { return untyped __global__.__hxcpp_get_utc_hours(mSeconds); }

	public function getUtcMinutes() : Int { return untyped __global__.__hxcpp_get_utc_minutes(mSeconds); }

	public function getUtcSeconds() : Int { return untyped __global__.__hxcpp_get_utc_seconds(mSeconds); }

	public function getUtcMilliseconds() : Int { return getMilliseconds(); }

	public function getUtcFullYear() : Int { return untyped __global__.__hxcpp_get_utc_year(mSeconds); }

	public function getUtcMonth() : Int { return untyped __global__.__hxcpp_get_utc_month(mSeconds); }

	public function getUtcDate() : Int { return untyped __global__.__hxcpp_get_utc_date(mSeconds); }

	public function getUtcDay() : Int { return untyped __global__.__hxcpp_get_utc_day(mSeconds); }

	public function isDST() : Bool { return ( 1 == (untyped __global__.__hxcpp_is_dst(mSeconds)) ); }

	public function timezoneOffset() : Int { return (untyped __global__.__hxcpp_timezone_offset(mSeconds)); } 

	public static function fromUTC( year : Int, month : Int, day : Int, hour : Int = 0, min : Int = 0, sec : Int = 0, millisec : Int = 0) : Date {
		basicCheck( year, month, day, hour, min, sec, millisec);
		var result = new Date( 0, 0, 1);
		result.mSeconds = untyped __global__.__hxcpp_from_utc( year, month, day, hour, min, sec, millisec);
		return result;
	}

	public function toUtcString():String { return untyped __global__.__hxcpp_to_utc_string(mSeconds); }

	public function toString():String { return untyped __global__.__hxcpp_to_string(mSeconds); }

	public static function now() : Date {
        var result = new Date(0, 0, 1);
        result.mSeconds = untyped __global__.__hxcpp_date_now();
        return result;
	}
  	private static function new1(t : Dynamic) : Date {
		return  new Date(2005,1,1,0,0,0);
	}

	public static function fromTime( t : Float) : Date {
		var result = new Date( 0, 0, 1);
		result.mSeconds = t*0.001;
		return result;
	}

	public static function fromString( s : String, isUtc : Bool = false) : Date {
		switch( s.length )
		{
			case 8:  // hh:mm:ss
			{
				var k = s.split(":");
				return isUtc ? Date.fromUTC( 0, 0, 1, Std.parseInt(k[0]), Std.parseInt(k[1]), Std.parseInt(k[2]) ) :
						new Date( 0, 0, 1, Std.parseInt(k[0]), Std.parseInt(k[1]), Std.parseInt(k[2]) );
			}
			case 10:  // YYYY-MM-DD
			{
				var k = s.split("-");
				return isUtc ? Date.fromUTC( Std.parseInt(k[0]), Std.parseInt(k[1])-1, Std.parseInt(k[2]) ) :
						new Date( Std.parseInt(k[0]), Std.parseInt(k[1])-1, Std.parseInt(k[2]) );
			}
			case 19:  // YYYY-MM-DD hh:mm:ss
			{
				var k = s.split(" ");
				var y = k[0].split("-");
				var t = k[1].split(":");
				return isUtc ? Date.fromUTC( Std.parseInt(y[0]), Std.parseInt(y[1])-1, Std.parseInt(y[2]),
											 Std.parseInt(t[0]), Std.parseInt(t[1]),   Std.parseInt(t[2]) ) :
								new Date( Std.parseInt(y[0]), Std.parseInt(y[1])-1, Std.parseInt(y[2]),
											Std.parseInt(t[0]), Std.parseInt(t[1]),   Std.parseInt(t[2]) );
			}
			default:
			{
				throw "Invalid date format : " + s;
			}
		}
	}

    /**
     * verifies whether the provided date parts are within valid range
     *    month: 0 to 11
     *    day: 1 to 31
     *    hour: 0 to 23
     *    min: 0 to 59
     *    sec: 0 to 59
     *    millisec: 0 to 999
     * else throws an exception describing the error.
     */
	static function basicCheck( year : Int, month : Int, day : Int, hour : Int, min : Int, sec : Int, millisec : Int) : Void
	{
		if  ((month < 0)     ||  (month > 11))      {  throw Std.string("Invalid month ('" + month + "'). Valid range (inclusive): 0 to 11");             }

			 // day of month = max limit is 31; does not check 30 day months
	 		 // does not check February month maximum i.e. 28 or 29(leap)
		if  ((day < 1)       ||  (day > 31))        {  throw Std.string("Invalid date (day of the month) ('" + day + "'). Valid range (inclusive): 1 to 31");    } 

		if  ((hour < 0)      ||  (hour > 23))       {  throw Std.string("Invalid hours ('" + hour + "'). Valid range (inclusive): 0 to 23");              }
		if  ((min < 0)       ||  (min > 59))        {  throw Std.string("Invalid minutes ('" + min + "'). Valid range (inclusive): 0 to 59");             }
		if  ((sec < 0)       ||  (sec > 59))        {  throw Std.string("Invalid seconds ('" + sec + "'). Valid range (inclusive): 0 to 59");             }
		if  ((millisec < 0)  ||  (millisec > 999))  {  throw Std.string("Invalid milliseconds ('" + millisec + "'). Valid range (inclusive): 0 to 999");  }
	}
}

