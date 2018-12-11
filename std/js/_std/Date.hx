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
@:coreApi extern class Date {

    function new(year : Int, month : Int, day : Int, hour : Int = 0, min : Int = 0, sec : Int = 0, millisec : Int = 0) : Void;

    inline function getTime() : Float {
        var t : Float = (untyped this).getTime();
        var o : Int = (untyped this).getTimezoneOffset();
        return t + o * 60.0 * 1000.0;
    }
    function getHours() : Int;
    function getMinutes() : Int;
    function getSeconds() : Int;
    function getMilliseconds() : Int;
    function getFullYear() : Int;
    function getMonth() : Int;
    function getDate() : Int;
    function getDay() : Int;

    inline function timezoneOffset() : Int { return (untyped this).getTimezoneOffset(); }
    inline function isDST() : Bool {
        // it is incorrect to fetch DST flag based on system settings
        // even for local timezone, based on date ... DST flag varies
        // e.g. a system could be currently in DST but a future Date object is not
        return false; // TODO: fix this
    }

    inline function getUtcHours() : Int
    {
        // Ugly hack to serving as a workaround for 2014 Samsung Smart TV bug
        // described in the http://stackoverflow.com/q/25214742/1310204
        var isSamsungSmartTv : Bool = untyped __js__("(typeof deviceapis != 'undefined' && typeof deviceapis.tv != 'undefined' && typeof deviceapis.tv.info != 'undefined')");
        if (isSamsungSmartTv)
        {
            // Samsung Smart TV, use the hack
            return (untyped getDstShiftedDate()).getUTCHours();
        }
        else
        {
            return (untyped this).getUTCHours(); 
        }
    }
    
    inline function getUtcMinutes() : Int
    { 
        return (untyped this).getUTCMinutes(); 
    }
    
    inline function getUtcSeconds() : Int
    { 
        return (untyped this).getUTCSeconds(); 
    }
    
    inline function getUtcMilliseconds() : Int 
    { 
        return (untyped this).getUTCMilliseconds(); 
    }
    
    inline function getUtcFullYear() : Int
    {
        // Ugly hack to serving as a workaround for 2014 Samsung Smart TV bug
        // described in the http://stackoverflow.com/q/25214742/1310204
        var isSamsungSmartTv : Bool = untyped __js__("(typeof deviceapis != 'undefined' && typeof deviceapis.tv != 'undefined' && typeof deviceapis.tv.info != 'undefined')");
        if (isSamsungSmartTv)
        {
            // Samsung Smart TV, use the hack
            return (untyped getDstShiftedDate()).getUTCFullYear();
        }
        else
        {
            return (untyped this).getUTCFullYear(); 
        }
    }
    
    inline function getUtcMonth() : Int
    {
        // Ugly hack to serving as a workaround for 2014 Samsung Smart TV bug
        // described in the http://stackoverflow.com/q/25214742/1310204
        var isSamsungSmartTv : Bool = untyped __js__("(typeof deviceapis != 'undefined' && typeof deviceapis.tv != 'undefined' && typeof deviceapis.tv.info != 'undefined')");
        if (isSamsungSmartTv)
        {
            // Samsung Smart TV, use the hack
            return (untyped getDstShiftedDate()).getUTCMonth();
        }
        else
        {
            return (untyped this).getUTCMonth(); 
        }
    }
    
    inline function getUtcDate() : Int
    {
        // Ugly hack to serving as a workaround for 2014 Samsung Smart TV bug
        // described in the http://stackoverflow.com/q/25214742/1310204
        var isSamsungSmartTv : Bool = untyped __js__("(typeof deviceapis != 'undefined' && typeof deviceapis.tv != 'undefined' && typeof deviceapis.tv.info != 'undefined')");
        if (isSamsungSmartTv)
        {
            // Samsung Smart TV, use the hack
            return (untyped getDstShiftedDate()).getUTCDate();
        }
        else
        {
            return (untyped this).getUTCDate(); 
        }
    }
    
    inline function getUtcDay() : Int
    {
        // Ugly hack to serving as a workaround for 2014 Samsung Smart TV bug
        // described in the http://stackoverflow.com/q/25214742/1310204
        var isSamsungSmartTv : Bool = untyped __js__("(typeof deviceapis != 'undefined' && typeof deviceapis.tv != 'undefined' && typeof deviceapis.tv.info != 'undefined')");
        if (isSamsungSmartTv)
        {
            // Samsung Smart TV, use the hack
            return (untyped getDstShiftedDate()).getUTCDay();
        }
        else
        {
            return (untyped this).getUTCDay(); 
        }
    }
    
    inline function toUtcString():String
    {
        var date : Dynamic;
        // Ugly hack to serving as a workaround for 2014 Samsung Smart TV bug
        // described in the http://stackoverflow.com/q/25214742/1310204
        var isSamsungSmartTv : Bool = untyped __js__("(typeof deviceapis != 'undefined' && typeof deviceapis.tv != 'undefined' && typeof deviceapis.tv.info != 'undefined')");
        if (isSamsungSmartTv)
        {
            // Samsung Smart TV, use the hack
            date = untyped getDstShiftedDate();
        }
        else
        {
            date = untyped this;
        }

        //getUTCMonth returns 0 based month (0 is January)
        var utcMonth : String = Std.string((date.getUTCMonth() + 1));
        //pad with a leading 0 for months before October
        var month : String = ("0" + utcMonth).substr(-2);

        var dayDate : String = ("0" + date.getUTCDate()).substr(-2);
        var hours : String = ("0" + date.getUTCHours()).substr(-2);
        var minutes : String = ("0" + date.getUTCMinutes()).substr(-2);
        var seconds : String = ("0" + date.getUTCSeconds()).substr(-2);

        return date.getUTCFullYear()
            + "-" + month
            + "-" + dayDate
            + " "
            + hours
            + ":" + minutes
            + ":" + seconds;
    }

    static inline function fromUTC( year : Int, month : Int, day : Int, hour : Int = 0, min : Int = 0, sec : Int = 0, millisec : Int = 0 ) : Date {
        return untyped __new__(Date, untyped Date.UTC(year,month,day,hour,min,sec,millisec));
    }

    inline function toString() : String {
        return untyped HxOverrides.dateStr(this);
    }

    static inline function now() : Date {
        return untyped __new__(Date);
    }

    static inline function fromTime( t : Float ) : Date {
        return untyped __new__(Date, t);
    }

    static inline function fromString( s : String, isUtc : Bool = false ) : Date {
        return untyped HxOverrides.strDate(s);
    }
    
    private inline function getDstShiftedDate() : Date
    {
        if (((this.getMonth() == 3 && this.getDate() >= 9) || (this.getMonth() > 3)) &&
                ((this.getMonth() == 11 && this.getDate() <= 2) || (this.getMonth() < 11)))
        {
            // DST (Daylight Saving Time) is active
            
            // Adjust the current time with taking into account DST offset
            var dstEpochTime : Dynamic = (untyped this).getTime() - 60 * 60 * 1000;
            var dstDate : Date = untyped __new__(Date, dstEpochTime);
            return dstDate;
        }
        else
        {
            return this;
        }
    }
}
