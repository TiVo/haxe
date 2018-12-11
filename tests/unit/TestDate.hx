package unit;

class TestDate extends Test {

    public function testDefaultArgs() : Void {
        var u : Date = new Date( 2013, 9, 2); 
        eq( u.getHours(), 0);
        eq( u.getMinutes(), 0);
        eq( u.getSeconds(), 0);
    }

    public function testMilliseconds() : Void {
        var c : Int  = 642;

        var u : Date = new Date( 2013, 9, 2, 10, 2, 0); 
        eq( 0, u.getMilliseconds());

        var v : Date = new Date( 2013, 9, 2, 10, 2, 0, c);
        eq( c, v.getMilliseconds());
        eq( c, v.getUtcMilliseconds());
        eq( Std.int(c), Std.int(v.getTime()-u.getTime()));

        var w : Date = DateTools.delta(u, c);
        eq( c, w.getMilliseconds());
        eq( v.getTime(), w.getTime());
    }

    public function testFromString() : Void {

        var u : Date = new Date( 2013, 9, 2, 0, 15, 0);
        var uStr : String = u.toString();
 
        var v : Date = Date.fromString( uStr);
        var vStr : String = v.toString();

        eq( uStr, vStr);

        eq( u.getTime(),         v.getTime());
        eq( u.getMonth(),        v.getMonth());
        eq( u.getHours(),        v.getHours());

        eq( u.getUtcDate(),      v.getUtcDate());
        eq( u.getUtcMinutes(),   v.getUtcMinutes());
        eq( u.getUtcFullYear(),  v.getUtcFullYear());

        // with UTC argument
        uStr = u.toUtcString();

        v = Date.fromString( uStr, true);
        vStr = v.toUtcString();

        eq( uStr, vStr);

        eq( u.getTime(),         v.getTime());
        eq( u.getMonth(),        v.getMonth());
        eq( u.getHours(),        v.getHours());

        eq( u.getUtcDate(),      v.getUtcDate());
        eq( u.getUtcMinutes(),   v.getUtcMinutes());
        eq( u.getUtcFullYear(),  v.getUtcFullYear());

        var TEST_DATE = "2001-02-04 08:16:32";
        var w : Date = Date.fromString(TEST_DATE, true);
        eq( w.getUtcFullYear(), 2001);
        eq( w.getUtcMonth(), 1); // API range for month: 0-11
        eq( w.getUtcDate(), 4);
        eq( w.getUtcHours(), 8);
        eq( w.getUtcMinutes(), 16);
        eq( w.getUtcSeconds(), 32);
    }

    public function testFromUTC() : Void {

        var utcSecs : Int = 0;
        var utcMins : Int = 15;
        var utcHour : Int = 0;
        var utcDofM : Int = 2;
        var utcMont : Int = 9;
        var utcYear : Int = 2013;

        var u : Date = Date.fromUTC( utcYear, utcMont, utcDofM, utcHour, utcMins, utcSecs);

        var v : Date = new Date(  u.getFullYear(), u.getMonth(), u.getDate(), u.getHours(), u.getMinutes(), u.getSeconds());

        eq( v.getUtcFullYear(),  utcYear);
        eq( v.getUtcMonth(),     utcMont);
        eq( v.getUtcDate(),      utcDofM);
        eq( v.getUtcHours(),     utcHour);
        eq( v.getUtcMinutes(),   utcMins);
        eq( v.getUtcSeconds(),   utcSecs);

        // Note: Asserts below assume Pacific TZ
        eq( u.getHours(),        17);
        eq( u.getMinutes(),      15);
        eq( u.getSeconds(),       0);
        eq( u.getDate(),          1);
        eq( u.getMonth(),         9);
        eq( u.getFullYear(),   2013);
    }

        // Note: All asserts in this below method assume Pacific TZ
    public function testUTCbasic() : Void {
        var localHr : Int;
        var utcHour : Int;
        var offsetH : Float;
        var secPerH : Int = 3600;

        localHr = 1; offsetH = -8.; 
        var q : Date = new Date( 2013,  2 , 10, localHr, 59, 59);    // 10 March 2013, 01:59:59 PST
        eq( q.getUtcHours(),     cast(( ( localHr - offsetH) % 24), Int)); 
        eq( q.timezoneOffset(),  cast( offsetH * secPerH, Int));

        localHr = 3; offsetH = -7.; 
        var r : Date = new Date( 2013,  2 , 10, localHr, 0, 0);      // 10 March 2013, 03:00:00 PDT
        eq( r.getUtcHours(),     cast(( ( localHr - offsetH) % 24), Int)); 
        eq( r.timezoneOffset(),  cast( offsetH * secPerH, Int));

        localHr = 1; offsetH = -7.; 
        var n : Date = new Date( 2013, 10 ,  3, localHr, 59, 59);    //  3 Nov 2013,   01:59:59 PDT
        eq( n.getUtcHours(),     cast(( ( localHr - offsetH) % 24), Int)); 
        eq( n.timezoneOffset(),  cast( offsetH * secPerH, Int));

        localHr = 2; offsetH = -8.; 
        var o : Date = new Date( 2013, 10 ,  3, localHr, 0, 0);      //  3 Nov 2013,   02:00:00 PST
        eq( o.getUtcHours(),     cast(( ( localHr - offsetH) % 24), Int)); 
        eq( o.timezoneOffset(),  cast( offsetH * secPerH, Int));

        localHr = 23; offsetH = -8.; 
        var k : Date = new Date( 2013, 11 , 31, localHr, 55, 0);     // 31 Dec 2013,   23:55:00 PST
        eq( k.getUtcFullYear(),  2014);
        eq( k.getUtcMonth(),        0);
        eq( k.getUtcDate(),         1);
        eq( k.getUtcHours(),        7);
        eq( k.getUtcMinutes(),     55);
        eq( k.timezoneOffset(),  cast( offsetH * secPerH, Int));
    }

        // Note: All asserts in this below method assume Pacific TZ
    public function testDSTbasic() : Void {
        var offsetH : Float;
        var secPerH : Int = 3600;

        offsetH = -8.;
        var p : Date = new Date( 2013,  2, 10, 1, 0, 0);       // 10 March 2013, 01:00:00 PST
        f( p.isDST());
        eq( p.timezoneOffset(), cast( offsetH * secPerH, Int));

        offsetH = -8.;
        var q : Date = new Date( 2013,  2 , 10, 1, 59, 59);    // 10 March 2013, 01:59:59 PST
        f( q.isDST());
        eq( q.timezoneOffset(), cast( offsetH * secPerH, Int));

        offsetH = -7.;
        var r : Date = new Date( 2013,  2 , 10, 2, 0, 0);      // 10 March 2013, 02:00:00 PDT
        t( r.isDST());
        eq( r.timezoneOffset(), cast( offsetH * secPerH, Int));

        offsetH = -7.;
        var x : Date = new Date( 2013,  2 , 10, 2, 0, 1);      // 10 March 2013, 02:00:01 PDT
        t( x.isDST());
        eq( x.timezoneOffset(), cast( offsetH * secPerH, Int));

        offsetH = -7.;
        var y : Date = new Date( 2013,  2 , 10, 3, 0, 0);      // 10 March 2013, 03:00:00 PDT  
        t( y.isDST());
        eq( y.timezoneOffset(), cast( offsetH * secPerH, Int));

        offsetH = -7.;
        var z : Date = new Date( 2013,  4 , 10, 3, 0, 1);      // 10 May 2013,   03:00:01 PDT
        t( z.isDST());
        eq( z.timezoneOffset(), cast( offsetH * secPerH, Int));

        offsetH = -7.;
        var m : Date = new Date( 2013, 10 ,  3, 1, 0, 0);      //  3 Nov 2013,   01:00:00 PDT
        t( m.isDST());
        eq( m.timezoneOffset(), cast( offsetH * secPerH, Int));

        offsetH = -7.;
        var n : Date = new Date( 2013, 10 ,  3, 1, 59, 59);    //  3 Nov 2013,   01:59:59 PDT
        t( n.isDST());
        eq( n.timezoneOffset(), cast( offsetH * secPerH, Int));

        offsetH = -8.;
        var o : Date = new Date( 2013, 10 ,  3, 2, 0, 0);      //  3 Nov 2013,   02:00:00 PST
        f( o.isDST());
        eq( o.timezoneOffset(), cast( offsetH * secPerH, Int));

        offsetH = -8.;
        var i : Date = new Date( 2013, 10 ,  3, 2, 0, 1);      //  3 Nov 2013,   02:00:01 PST    
        f( i.isDST());
        eq( i.timezoneOffset(), cast( offsetH * secPerH, Int));

        offsetH = -8.;
        var j : Date = new Date( 2013, 10 ,  3, 3, 0, 0);      //  3 Nov 2013,   03:00:00 PST 
        f( j.isDST());
        eq( j.timezoneOffset(), cast( offsetH * secPerH, Int));
    }

        // Note: All asserts in this below method assume Pacific TZ
    public function testSpringForwardDST() : Void {
        var tzOffsetInHours : Int;
        var milliSecPerHr   : Int = 3600 * 1000;

        var u : Date = Date.fromUTC( 2013, 2, 10,  8, 30);  // UTC :  8.30 AM 10  Mar 2013,   PST :  12.30 AM 10  Mar 2013
        var v : Date = Date.fromUTC( 2013, 2, 10,  9, 30);  // UTC :  9.30 AM 10  Mar 2013,   PST :   1.30 AM 10  Mar 2013
        var w : Date = Date.fromUTC( 2013, 2, 10, 10, 30);  // UTC : 10.30 AM 10  Mar 2013,   PDT :   3.30 AM 10  Mar 2013
        var x : Date = Date.fromUTC( 2013, 2, 10, 11, 30);  // UTC : 11.30 AM 10  Mar 2013,   PDT :   4.30 AM 10  Mar 2013
        var y : Date = Date.fromUTC( 2013, 2, 10,  2,  0);  // UTC :  2.00 AM 10  Mar 2013,   PST :   6.00 PM  9  Mar 2013
        var z : Date = Date.fromUTC( 2013, 2, 10,  3,  0);  // UTC :  3.00 AM 10  Mar 2013,   PST :   7.00 PM  9  Mar 2013

        f(  u.isDST());
        eq( u.getUtcDate(), u.getDate());
        eq( u.getUtcMonth(), u.getMonth());
        eq( u.getUtcHours(),  8);                   // UTC   8am
        eq( u.getHours(),     0);                   // PST  12am
        eq( u.getUtcMinutes(), u.getMinutes());
        tzOffsetInHours = cast( u.timezoneOffset()/3600);
        eq( tzOffsetInHours,  -8);                   
        eq(( u.getUtcHours()+tzOffsetInHours), u.getHours());

        eq(( u.getTime()+milliSecPerHr), v.getTime());

        f(  v.isDST());
        eq( v.getUtcDate(), v.getDate());
        eq( v.getUtcMonth(), v.getMonth());
        eq( v.getUtcHours(),  9);                   // UTC   9am 
        eq( v.getHours(),     1);                   // PST   1am 
        eq( v.getUtcMinutes(), v.getMinutes());
        tzOffsetInHours = cast( v.timezoneOffset()/3600);
        eq( tzOffsetInHours,  -8);                   
        eq(( v.getUtcHours()+tzOffsetInHours), v.getHours());

        eq(( v.getTime()+milliSecPerHr), w.getTime());

        t(   w.isDST());
        eq( w.getUtcDate(), w.getDate());
        eq( w.getUtcMonth(), w.getMonth());
        eq( w.getUtcHours(), 10);                   // UTC  10am 
        eq( w.getHours(),     3);                   // PDT   3am 
        eq( w.getUtcMinutes(), w.getMinutes());
        tzOffsetInHours = cast( w.timezoneOffset()/3600);
        eq( tzOffsetInHours,  -7);                   
        eq(( w.getUtcHours()+tzOffsetInHours), w.getHours());

        eq(( w.getTime()+milliSecPerHr), x.getTime());

        t(   x.isDST());
        eq( x.getUtcDate(), x.getDate());
        eq( x.getUtcMonth(), x.getMonth());
        eq( x.getUtcHours(), 11);                   // UTC  11am 
        eq( x.getHours(),     4);                   // PST   4am 
        eq( x.getUtcMinutes(), x.getMinutes());
        tzOffsetInHours = cast( x.timezoneOffset()/3600);
        eq( tzOffsetInHours,  -7);                   
        eq(( x.getUtcHours()+tzOffsetInHours), x.getHours());

        f(  y.isDST());
        eq( y.getUtcDate(),  10);
        eq( y.getUtcMonth(), y.getMonth());
        eq( y.getUtcHours(),  2);                   // UTC   2am
        eq( y.getDate(),      9);
        eq( y.getHours(),    18);                   // PST   6pm
        eq( y.getUtcMinutes(), y.getMinutes());
        tzOffsetInHours = cast( y.timezoneOffset()/3600);
        eq( tzOffsetInHours,  -8);

        eq(( y.getTime()+milliSecPerHr), z.getTime());

        f(  z.isDST());
        eq( z.getUtcDate(),  10);
        eq( z.getUtcMonth(), z.getMonth());
        eq( z.getUtcHours(),  3);                   // UTC   3am
        eq( z.getDate(),      9);
        eq( z.getHours(),    19);                   // PST   7pm
        eq( z.getUtcMinutes(), z.getMinutes());
        tzOffsetInHours = cast( z.timezoneOffset()/3600);
        eq( tzOffsetInHours,  -8);
    }

        // Note: All asserts in this below method assume Pacific TZ
    public function testFallbackDST() : Void {
        var tzOffsetInHours : Int;
        var milliSecPerHr   : Int = 3600 * 1000;

        var u : Date = Date.fromUTC( 2013, 10, 3,  7, 30);  // UTC :  7.30 AM 3 Nov 2013,   PDT :  12.30 AM 3 Nov 2013
        var v : Date = Date.fromUTC( 2013, 10, 3,  8, 30);  // UTC :  8.30 AM 3 Nov 2013,   PDT :   1.30 AM 3 Nov 2013
        var w : Date = Date.fromUTC( 2013, 10, 3,  9, 30);  // UTC :  9.30 AM 3 Nov 2013,   PST :   1.30 AM 3 Nov 2013
        var x : Date = Date.fromUTC( 2013, 10, 3, 10, 30);  // UTC : 10.30 AM 3 Nov 2013,   PST :   2.30 AM 3 Nov 2013
        var y : Date = Date.fromUTC( 2013, 10, 3,  9,  0);  // UTC :  9.00 AM 3 Nov 2013,   PDT :   2.00 AM 3 Nov 2013
        var z : Date = Date.fromUTC( 2013, 10, 3, 10,  0);  // UTC : 10.00 AM 3 Nov 2013,   PST :   2.00 AM 3 Nov 2013

        t(   u.isDST());
        eq( u.getUtcDate(), u.getDate());
        eq( u.getUtcMonth(), u.getMonth());
        eq( u.getUtcHours(),  7);                   // UTC   7am
        eq( u.getHours(),     0);                   // PDT  12am
        eq( u.getUtcMinutes(), u.getMinutes());
        tzOffsetInHours = cast( u.timezoneOffset()/3600);
        eq( tzOffsetInHours,  -7);                   
        eq(( u.getUtcHours()+tzOffsetInHours), u.getHours());

        eq(( u.getTime()+milliSecPerHr), v.getTime());

        t(   v.isDST());
        eq( v.getUtcDate(), v.getDate());
        eq( v.getUtcMonth(), v.getMonth());
        eq( v.getUtcHours(),  8);                   // UTC   8am 
        eq( v.getHours(),     1);                   // PDT   1am 
        eq( v.getUtcMinutes(), v.getMinutes());
        tzOffsetInHours = cast( v.timezoneOffset()/3600);
        eq( tzOffsetInHours,  -7);                   
        eq(( v.getUtcHours()+tzOffsetInHours), v.getHours());

        eq(( v.getTime()+milliSecPerHr), w.getTime());

        f(  w.isDST());
        eq( w.getUtcDate(), w.getDate());
        eq( w.getUtcMonth(), w.getMonth());
        eq( w.getUtcHours(),  9);                   // UTC   9am 
        eq( w.getHours(),     1);                   // PST   1am 
        eq( w.getUtcMinutes(), w.getMinutes());
        tzOffsetInHours = cast( w.timezoneOffset()/3600);
        eq( tzOffsetInHours,  -8);                   
        eq(( w.getUtcHours()+tzOffsetInHours), w.getHours());

        eq(( w.getTime()+milliSecPerHr), x.getTime());

        f(  x.isDST());
        eq( x.getUtcDate(), x.getDate());
        eq( x.getUtcMonth(), x.getMonth());
        eq( x.getUtcHours(), 10);                   // UTC  10am 
        eq( x.getHours(),     2);                   // PST   2am 
        eq( x.getUtcMinutes(), x.getMinutes());
        tzOffsetInHours = cast( x.timezoneOffset()/3600);
        eq( tzOffsetInHours,  -8);                   
        eq(( x.getUtcHours()+tzOffsetInHours), x.getHours());

        // note: sharp at 2am, it rolls back... there are two 1:59:59.999s but only one 2:00:00.000
        f(  y.isDST()); 
        eq( y.getUtcDate(), y.getDate());
        eq( y.getUtcMonth(), y.getMonth());
        eq( y.getUtcHours(),  9);                   // UTC   9am 
        eq( y.getHours(),     1);                   // PDT   2am 
        eq( y.getUtcMinutes(), y.getMinutes());
        tzOffsetInHours = cast( y.timezoneOffset()/3600);
        eq( tzOffsetInHours,  -8);                   
        eq(( y.getUtcHours()+tzOffsetInHours), y.getHours());

        eq(( y.getTime()+milliSecPerHr), z.getTime());

        f(  z.isDST());
        eq( z.getUtcDate(), z.getDate());
        eq( z.getUtcMonth(), z.getMonth());
        eq( z.getUtcHours(), 10);                   // UTC  10am 
        eq( z.getHours(),     2);                   // PST   2am 
        eq( z.getUtcMinutes(), z.getMinutes());
        tzOffsetInHours = cast( z.timezoneOffset()/3600);
        eq( tzOffsetInHours,  -8);                   
        eq(( z.getUtcHours()+tzOffsetInHours), z.getHours());
    }

    public function testBasicCheck() : Void {
        //
        // NOTE: this method is not using org.hamcrest.MatchersBase.assertThat
        // as it introduces dependency in order to build haxe lang unit tests.
        //

        var u : Date;
        var min : Int;
        var max : Int;
        var e : Bool; // indicates whether exception should occur 

        //--- year
        min = 1970;

        e = true; 
        try { u = new Date( min-1, 9, 2); t( ! e); }
        catch ( s : String ) { t( e); } 

        e = false; 
        try { u = new Date( min, 9, 2); t( ! e); }
        catch ( s : String ) { t( e); } 

        e = false; 
        try { u = new Date( min+1, 9, 2); t( ! e); }
        catch ( s : String ) { t( e); } 

        e = false; 
        try { u = new Date( 2019, 9, 2); t( ! e); }
        catch ( s : String ) { t( e); } 

        e = false; 
        try { u = new Date( 2039, 9, 2); t( ! e); }
        catch ( s : String ) { t( e); } 

        //--- month
        min =  0;
        max = 11;

        e = true; 
        try { u = new Date( 2013, min-1, 2); t( ! e); }
        catch ( s : String ) { t( e); } 

        e = false; 
        try { u = new Date( 2013, min, 2); t( ! e); }
        catch ( s : String ) { t( e); } 

        e = false; 
        try { u = new Date( 2013, max, 2); t( ! e); }
        catch ( s : String ) { t( e); } 

        e = true; 
        try { u = new Date( 2013, max+1, 2); t( ! e); }
        catch ( s : String ) { t( e); } 

        //--- day
        min =  1;
        max = 31;

        e = true; 
        try { u = new Date( 2013, 9, min-1); t( ! e); }
        catch ( s : String ) { t( e); } 

        e = false; 
        try { u = new Date( 2013, 9, min); t( ! e); }
        catch ( s : String ) { t( e); } 

        e = false; 
        try { u = new Date( 2013, 1, 28); t( ! e); }
        catch ( s : String ) { t( e); } 

        e = false;
        try { u = new Date( 2013, 1, 29); t( ! e); }
        catch ( s : String ) { t( e); } 

        e = false; 
        try { u = new Date( 2013, 8, 30); t( ! e); }
        catch ( s : String ) { t( e); } 

        e = false; 
        try { u = new Date( 2013, 8, max); t( ! e); }
        catch ( s : String ) { t( e); } 

        e = true; 
        try { u = new Date( 2013, 8, max+1); t( ! e); }
        catch ( s : String ) { t( e); } 

        //--- hours
        min =  0;
        max = 23;

        e = true; 
        try { u = new Date( 2013, 9, 30, min-1); t( ! e); }
        catch ( s : String ) { t( e); } 

        e = false; 
        try { u = new Date( 2013, 9, 30, min); t( ! e); }
        catch ( s : String ) { t( e); } 

        e = false; 
        try { u = new Date( 2013, 9, 30, max); t( ! e); }
        catch ( s : String ) { t( e); } 

        e = true; 
        try { u = new Date( 2013, 9, 30, max+1); t( ! e); }
        catch ( s : String ) { t( e); } 

        //--- minutes
        min =  0;
        max = 59;

        e = true; 
        try { u = new Date( 2013, 9, 30, 0, min-1); t( ! e); }
        catch ( s : String ) { t( e); } 

        e = false; 
        try { u = new Date( 2013, 9, 30, 0, min); t( ! e); }
        catch ( s : String ) { t( e); } 

        e = false; 
        try { u = new Date( 2013, 9, 30, 0, max); t( ! e); }
        catch ( s : String ) { t( e); } 

        e = true; 
        try { u = new Date( 2013, 9, 30, 0, max+1); t( ! e); }
        catch ( s : String ) { t( e); } 

        //--- seconds
        min =  0;
        max = 59;

        e = true; 
        try { u = new Date( 2013, 9, 30, 0, 0, min-1); t( ! e); }
        catch ( s : String ) { t( e); } 

        e = false; 
        try { u = new Date( 2013, 9, 30, 0, 0, min); t( ! e); }
        catch ( s : String ) { t( e); } 

        e = false; 
        try { u = new Date( 2013, 9, 30, 0, 0, max); t( ! e); }
        catch ( s : String ) { t( e); } 

        e = true; 
        try { u = new Date( 2013, 9, 30, 0, 0, max+1); t( ! e); }
        catch ( s : String ) { t( e); } 

        //--- milliseconds
        min =   0;
        max = 999;

        e = true; 
        try { u = new Date( 2013, 9, 30, 0, 0, 0, min-1); t( ! e); }
        catch ( s : String ) { t( e); } 

        e = false; 
        try { u = new Date( 2013, 9, 30, 0, 0, 0, min); t( ! e); }
        catch ( s : String ) { t( e); } 

        e = false; 
        try { u = new Date( 2013, 9, 30, 0, 0, 0, max); t( ! e); }
        catch ( s : String ) { t( e); } 

        e = true; 
        try { u = new Date( 2013, 9, 30, 0, 0, 0, max+1); t( ! e); }
        catch ( s : String ) { t( e); } 
    }
}
