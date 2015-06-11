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

/**
 * The SocketSelector class allows a select() function to be called in a
 * cancellable manner.
**/
extern class SocketSelector
{
    /**
     * Create a SocketSelector, which can be used to do a cancellable select
     * operation.
     **/
    function new() : Void;

	/**
     * Wait until one of the sockets groups is ready for the given operation,
     * modifying the input socket groups accordingly:
     * [read] contains sockets on which we want to wait for available data to
     *        be read; only those sockets which have data available for read
     *        at the time that the select function returns will remain in the
     *        Array.
     * [write] contains sockets on which we want to wait until we are allowed
     *         to write some data to their output buffers; only those sockets
     *         which are allowed to write at the time that the select function
     *         returns will remain in the Array.
     * [others] contains sockets on which we want to wait for exceptional
     *          conditions; only those sockets which have exception conditions
     *          at the time that the select function returns will remain in
     *          the Array.
     * select will block until one of the condition is met, or until
     *        cancel() is called, in which case it will return the sockets
     *        for which the condition was true.
     * In case a [timeout] (in seconds) is specified, select might wait at
     * worse until the timeout expires.
     **/
    function select(read : Null<Array<Socket>>, write : Null<Array<Socket>>,
                    others : Null<Array<Socket>>, ?timeout : Float) : Void;

    /**
     * Cancel a select in progress.  Only has effect if a select is in
     * progress.  Note that this is only useful on multi-threaded platforms,
     * for which a thread may call cancel() while another thread is blocked in
     * select().
     **/
    function cancel() : Void;

    /**
     * Closes a SocketSelector which is no longer needed.  If this is not
     * called, the SocketSelector will leak resources.
     **/
    public function close()
    {
    }
}
