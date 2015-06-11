/*
 * Copyright (C)2015 Haxe Foundation
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
package sys.net;


class SocketSelector
{
    public function new()
    {
        mArray = [ ];
        socket_selector_initialize(mArray);
    }

    public function select(read : Null<Array<Socket>>,
                           write : Null<Array<Socket>>,
                           others : Null<Array<Socket>>,
                           ?timeout : Float) : Void
    {
        socket_selector_select(mArray, read, write, others, timeout);
    }

    public function cancel() : Void
    {
        socket_selector_cancel(mArray);
    }

    public function close() : Void
    {
        socket_selector_close(mArray);
    }

	private static var socket_selector_initialize = 
        neko.Lib.load("std","socket_selector_initialize", 1);
	private static var socket_selector_select =
        neko.Lib.load("std","socket_selector_select", 5);
	private static var socket_selector_cancel =
        neko.Lib.load("std","socket_selector_cancel", 1);
	private static var socket_selector_close =
        neko.Lib.load("std","socket_selector_close", 1);

	private var mArray : Array<Dynamic>;
}
