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
        mMutex = new java.vm.Mutex();
    }

    public function select(read : Null<Array<Socket>>,
                           write : Null<Array<Socket>>,
                           others : Null<Array<Socket>>,
                           ?timeout : Float) : Void
    {
        var ret = this.do_select(read, write, others, timeout);
        if (read != null) {
            read.splice(0, read.length);
            if (ret != null) {
                while (ret.read.length > 0) {
                    read.push(ret.read.pop());
                }
            }
        }
        if (write != null) {
            write.splice(0, write.length);
            if (ret != null) {
                while (ret.write.length > 0) {
                    write.push(ret.write.pop());
                }
            }
        }
        if (others != null) {
            others.splice(0, others.length);
            if (ret != null) {
                while (ret.others.length > 0) {
                    others.push(ret.others.pop());
                }
            }
        }
    }

    public function cancel() : Void
    {
        mMutex.acquire();
        if (mSelector == null) {
            mCancelled = true;
            mMutex.release();
            return;
        }
        var this_selector = mSelector;
        mMutex.release();

        try {
            var ignore = untyped __java__('this_selector.wakeup()');
        } 
        catch (e : Dynamic)
        {
            // Ignore this exception.  If do_select() had already closed
            // the selector before wakeup was called, then a
            // ClosedSelectorException would be thrown, ignore it.
        }
    }

    public function close()
    {
    }
    
    private function do_select(read : Array<Socket>,
                               write : Array<Socket>,
                               others : Array<Socket>,
                               ?timeout : Float) : 
    { read : Array<Socket>, write : Array<Socket>, others : Array<Socket> }
    {
        try {
            mMutex.acquire();
            if (mCancelled) {
                mCancelled = false;
                mMutex.release();
                return null;
            }
            mSelector = java.nio.channels.Selector.open();
            mMutex.release();
        }
        catch (e : Dynamic) {
            throw e;
        }
        try {
            if (read != null) {
                for (s in read) {
                    if (s.clientChannel != null) {
                        s.clientChannel.register
                            (mSelector,
                             java.nio.channels.SelectionKey.OP_READ).attach(s);
                    }
                    else if (s.server != null) {
                        s.serverChannel.register
                            (mSelector,
                           java.nio.channels.SelectionKey.OP_ACCEPT).attach(s);
                    }
                }
            }
            if (write != null) {
                for (s in write) {
                    if (s.clientChannel != null) {
                        s.clientChannel.register
                            (mSelector,
                             java.nio.channels.SelectionKey.OP_WRITE).attach(s);
                    }
                }
            }
            var ret : Int;
            
            if (timeout == null) {
                ret = untyped __java__('mSelector.select(0)');
            }
            else {
                var ms = Std.int(timeout * 1000);
                if (ms == 0) {
                    ret = mSelector.selectNow();
                }
                else {
                    ret = untyped __java__('mSelector.select(ms)');
                }
            }
            var read_ret : Array<Socket> = [ ];
            var write_ret : Array<Socket> = [ ];
            var others_ret : Array<Socket> = [ ];
            if (ret > 0) {
                var keyIterator = mSelector.selectedKeys().iterator();
                while (keyIterator.hasNext()) {
                    var key = keyIterator.next();
                    if (key.isAcceptable() || key.isReadable()) {
                        read_ret.push(cast(key.attachment(), Socket));
                    }
                    else if (key.isWritable()) {
                        write_ret.push(cast(key.attachment(), Socket));
                    }
                }
            }
            var selector = mSelector;
            mSelector = null;
            selector.close();
            return { read : read_ret, write : write_ret, others : others_ret };
        }
        catch (e : Dynamic) {
            try {
                if (mSelector != null) {
                    var selector = mSelector;
                    mSelector = null;
                    selector.close();
                }
            }
            catch (e : Dynamic) {
                throw e;
            }
            throw e;
        }
    }

	private var mSelector : java.nio.channels.Selector;
    private var mMutex : java.vm.Mutex;
    private var mCancelled : Bool;
}
