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
package;
import haxe.Int64;
import java.util.Locale;
import java.util.TimeZone;
import java.util.Calendar;
import java.util.GregorianCalendar;

@:coreApi class Date
{
    private var utcCalendar : Calendar;
    private var calendar : Calendar;

	public function new(year : Int, month : Int, day : Int, hour : Int = 0, min : Int = 0, sec : Int = 0, millisec : Int = 0) : Void
	{
        utcCalendar = new GregorianCalendar(TimeZone.getTimeZone("UTC"));
        // We have to 0 out the time becuase the set later on will only change the year, month
        // day, hour, min, and sec leaving milliseconds or factions of the second unchanged.
        // Many consider this a bug. Lots of debate in the forums about this over the years.
        utcCalendar.setTimeInMillis(Int64.make(0,0));
        utcCalendar.set(year, month, day, hour, min, sec);

        if (millisec > 0)
        {
          //milliseconds adjustment
            utcCalendar.setTimeInMillis(Int64.add(utcCalendar.getTimeInMillis(), Int64.make(0, millisec)));
        }
	}

    private inline function ensureLocalCalendarExists() : Void
    {
        if (calendar == null)
        {
            calendar = new GregorianCalendar();
            calendar.setTimeInMillis(utcCalendar.getTimeInMillis());
        }
    }

	public inline function getTime() : Float
	{
        ensureLocalCalendarExists();
		return cast calendar.getTimeInMillis();
	}

	public inline function getHours() : Int
	{
        ensureLocalCalendarExists();
        return calendar.get(Calendar.HOUR_OF_DAY);
	}

	public inline function getMinutes() : Int
	{
        ensureLocalCalendarExists();
        return calendar.get(Calendar.MINUTE);
	}

	public inline function getSeconds() : Int
	{
        ensureLocalCalendarExists();
        return calendar.get(Calendar.SECOND);
	}

    public function getMilliseconds() : Int
    {
        ensureLocalCalendarExists();
        return Int64.getLow(calendar.getTimeInMillis());
    }

	public inline function getFullYear() : Int
	{
        ensureLocalCalendarExists();
        return calendar.get(Calendar.YEAR);
	}

	public inline function getMonth() : Int
	{
        ensureLocalCalendarExists();
        return calendar.get(Calendar.MONTH);
	}

	public inline function getDate() : Int
	{
        ensureLocalCalendarExists();
        return calendar.get(Calendar.DATE);
	}

	public inline function getDay() : Int
	{
        ensureLocalCalendarExists();
        return calendar.get(Calendar.DAY_OF_WEEK);
	}

    public function timezoneOffset() : Int
    {
        return cast((TimeZone.getDefault().getRawOffset() + TimeZone.getDefault().getDSTSavings())/1000);
    }

    public function isDST() : Bool {
        // it is incorrect to fetch DST flag based on system settings
        // even for local timezone, based on date ... DST flag varies
        // e.g. a system could be currently in DST but a future Date object is not

        return false; // TODO: fix this
    }

    public function getUtcHours() : Int {
        return utcCalendar.get(Calendar.HOUR_OF_DAY);
    }

    public function getUtcMinutes() : Int {
        return utcCalendar.get(Calendar.MINUTE);
    }

    public function getUtcSeconds() : Int {
        return utcCalendar.get(Calendar.SECOND);
    }

    public function getUtcMilliseconds() : Int {
        return Int64.getLow(utcCalendar.getTimeInMillis());
    }

    public function getUtcFullYear() : Int {
        return utcCalendar.get(Calendar.YEAR);
    }

    public function getUtcMonth() : Int {
        return utcCalendar.get(Calendar.MONTH);
    }

    public function getUtcDate() : Int {
        return utcCalendar.get(Calendar.DATE);
    }

    public function getUtcDay() : Int {
        return utcCalendar.get(Calendar.DAY_OF_WEEK);
    }

    public static function fromUTC( year : Int, month : Int, day : Int, hour : Int = 0, min : Int = 0, sec : Int = 0, millisec : Int = 0 ) : Date {
        var d : Date = new Date(year,month,day,hour,min,sec,millisec);
        return fromTime(d.getTime());
    }

    public function toUtcString():String { 
                // XXX: Fix for UTC.
                var m = getUtcMonth() + 1;
                var d = getUtcDate();
                var h = getUtcHours();
                var mi =getUtcMinutes();
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
		var mi =getMinutes();
		var s = getSeconds();
		return (getFullYear())
			+"-"+(if( m < 10 ) "0"+m else ""+m)
			+"-"+(if( d < 10 ) "0"+d else ""+d)
			+" "+(if( h < 10 ) "0"+h else ""+h)
			+":"+(if( mi < 10 ) "0"+mi else ""+mi)
			+":"+(if( s < 10 ) "0"+s else ""+s);
	}

	public static function now() : Date
	{
           var d = new Date(0, 0, 0, 0, 0, 0);
           d.utcCalendar = Calendar.getInstance(TimeZone.getTimeZone("UTC"));
           return d;
	}

	public static function fromTime( t : Float ) : Date
	{
		var d = new Date(0, 0, 0, 0, 0, 0);
		d.utcCalendar.setTimeInMillis(cast(t,Int64));
		return d;
	}

	public static function fromString( s : String, isUtc : Bool = false ) : Date
	{
		switch( s.length )
		{
			case 8: // hh:mm:ss
				var k = s.split(":");
                return isUtc ? Date.fromUTC( 0, 0, 1, Std.parseInt(k[0]), Std.parseInt(k[1]), Std.parseInt(k[2]) ) :
                        new Date( 0, 0, 1, Std.parseInt(k[0]), Std.parseInt(k[1]), Std.parseInt(k[2]) );
			case 10: // YYYY-MM-DD
				var k = s.split("-");
                return isUtc ? Date.fromUTC( Std.parseInt(k[0]), Std.parseInt(k[1])-1, Std.parseInt(k[2]) ) :
                        new Date( Std.parseInt(k[0]), Std.parseInt(k[1])-1, Std.parseInt(k[2]) );
			case 19: // YYYY-MM-DD hh:mm:ss
				var k = s.split(" ");
				var y = k[0].split("-");
				var t = k[1].split(":");
                return isUtc ? Date.fromUTC( Std.parseInt(y[0]), Std.parseInt(y[1])-1, Std.parseInt(y[2]),
                                             Std.parseInt(t[0]), Std.parseInt(t[1]),   Std.parseInt(t[2]) ) :
                        new Date( Std.parseInt(y[0]), Std.parseInt(y[1])-1, Std.parseInt(y[2]),
                                Std.parseInt(t[0]), Std.parseInt(t[1]),   Std.parseInt(t[2]) );
			default:
				throw "Invalid date format : " + s;
		}
	}
}
