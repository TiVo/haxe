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
package sys.net;

import haxe.io.Bytes;
import haxe.io.Eof;
import java.io.IOException;
import java.io.EOFException;

@:allow(sys.net.SocketSelector)
@:coreApi
class Socket
{
	public var input(default, null) : haxe.io.Input;
	public var output(default, null) : haxe.io.Output;

	public var custom : Dynamic;

    private var clientChannel : java.nio.channels.SocketChannel;
    private var serverChannel : java.nio.channels.ServerSocketChannel;

    private var client : java.net.Socket;
    private var server : java.net.ServerSocket;

    private var blocking : Bool;
	private var bindAddr : java.net.SocketAddress;

	public function new() : Void
	{
        this.blocking = true;
	}

	public function close() : Void
	{
		try {
            if (this.clientChannel != null) {
                this.clientChannel.close();
                this.clientChannel = null;
                this.client = null;
            }
            else if (this.serverChannel != null) {
                this.serverChannel.close();
                this.serverChannel = null;
                this.server = null;
            }
            this.blocking = true;
            this.bindAddr = null;
            this.input = null;
            this.output = null;
		}
		catch (e : Dynamic) {
            throw e;
        }
	}

	public function read() : String
	{
		var buf = Bytes.alloc(8192);
		var total = new haxe.io.BytesBuffer();
        while (true) {
            var len = this.input.readBytes(buf, 0, 8192);
            if (len == 0) {
                break;
            }
            total.addBytes(buf, 0, len);
		}
        return total.getBytes().toString();
	}

	public function write(content : String) : Void
	{
		output.writeString(content);
	}

	public function connect(host : Host, port : Int) : Void
	{
        if (client != null) {
            throw "Can't connect an open Socket";
        }
        if (server != null) {
            throw "Can't connect a listening Socket";
        }
        try {
            this.clientChannel = java.nio.channels.SocketChannel.open();
            this.clientChannel.connect
                (new java.net.InetSocketAddress(host.wrapped, port));
            this.client = this.clientChannel.socket();
			this.input = new SocketInput(this.clientChannel);
			this.output = new SocketOutput(this.clientChannel);
            this.setBlocking(this.blocking);
		}
		catch (e : Dynamic) {
            throw e;
        }
	}

	public function listen(connections : Int) : Void
	{
        if (this.client != null) {
            throw "Can't listen on an open Socket";
        }
        if (this.server != null) {
            throw "Can't re-listen on a listening Socket";
        }
		if (this.bindAddr == null) {
            throw "You must bind the Socket to an address!";
        }
		try {
            this.serverChannel = java.nio.channels.ServerSocketChannel.open();
            // For some reason, the Haxe version of the Java standard
            // libraries does not have this version of bind
            // this.server = 
            //     this.serverChannel.bind(this.bindAddr, connections);
            this.server = this.serverChannel.socket();
            this.server.bind(this.bindAddr);
            this.setBlocking(this.blocking);
        }
		catch (e : Dynamic) {
            throw e;
        }
	}

	public function shutdown(read : Bool, write : Bool) : Void
	{
        if (this.client == null) {
            throw "Can't shutdown an unopened Socket";
        }
		try
		{
			if (read) {
                this.client.shutdownInput();
            }
			if (write) {
                this.client.shutdownOutput();
            }
		}
		catch (e : Dynamic) {
            throw e;
        }
	}

	public function bind(host : Host, port : Int) : Void
	{
        if (this.server != null) {
            throw "Can't change bind address of listening Socket";
        }
		this.bindAddr = new java.net.InetSocketAddress(host.wrapped, port);
	}

	public function accept() : Socket
	{
        if (this.server == null) {
            throw "Can't accept on a Socket that is not listening";
        }
        try {
            var ret = new Socket();
            ret.clientChannel = this.serverChannel.accept();
            if (ret.clientChannel == null) {
                return null;
            }
            ret.client = ret.clientChannel.socket();
            ret.input = new SocketInput(ret.clientChannel);
            ret.output = new SocketOutput(ret.clientChannel);
            return ret;
        }
        catch (e : Dynamic) {
            throw e;
        }
	}

	public function peer() : { host : Host, port : Int }
	{
        if (this.client == null) {
            throw "Can't get peer of unopened Socket";
        }
		var rem : java.net.InetSocketAddress = 
            cast this.client.getInetAddress();
		if (rem == null) {
            return null;
        }
		var host = new Host(null);
		host.wrapped = rem.getAddress();
		return { host: host, port: this.client.getPort() };
	}

	public function host() : { host : Host, port : Int }
	{
		var local = null;
        var port : Int;
        if (this.client == null) {
            if (this.server == null) {
                throw "Can't get host of closed Socket";
            }
            else {
                local = this.server.getInetAddress();
                port = this.server.getLocalPort();
            }
        }
        else {
                local = this.client.getLocalAddress();
                port = this.client.getLocalPort();
        }
		var host = new Host(null);
		host.wrapped = local;
		return { host : host, port : port };
	}

	public function setTimeout(timeout : Float) : Void
	{
		try {
            if (this.client != null) {
                this.client.setSoTimeout(Std.int(timeout * 1000));
            }
            else if (this.server != null) {
                this.server.setSoTimeout(Std.int(timeout * 1000));
            }
        }
		catch (e : Dynamic) {
            throw e;
        }
	}

	public function waitForRead() : Void
	{
        if (this.client == null) {
            throw "Can't wait for read on unopened Socket";
        }
        try {
            var selector = java.nio.channels.Selector.open();
            this.clientChannel.register
                (selector, java.nio.channels.SelectionKey.OP_READ);
            selector.select();
            selector.close();
        }
        catch (e : Dynamic) {
            throw e;
        }
	}

	public function setBlocking(b : Bool) : Void
	{
        try {
            if (clientChannel != null) {
                clientChannel.configureBlocking(b);
                cast(input, SocketInput).setBlocking(b);
                cast(output, SocketOutput).setBlocking(b);
            }
            else if (serverChannel != null) {
                serverChannel.configureBlocking(b);
            }
            this.blocking = b;
        }
        catch (e : Dynamic) {
            throw e;
        }
	}

	public function setFastSend( b : Bool ) : Void
	{
        if (this.client == null) {
            throw "Can't set fast send on unopened Socket";
        }
		try {
			this.client.setTcpNoDelay(b);
        }
		catch (e : Dynamic) {
            throw e;
        }
	}

	public static function select(read : Array<Socket>,
                                  write : Array<Socket>,
                                  others : Array<Socket>,
                                  ?timeout : Float) : 
        { read : Array<Socket>, write : Array<Socket>, others : Array<Socket> }
	{
        var selector : java.nio.channels.Selector;
        try {
            selector = java.nio.channels.Selector.open();
        }
        catch (e : Dynamic) {
            throw e;
        }
        try {
            for (s in read) {
                if (s.clientChannel != null) {
                    s.clientChannel.register
                        (selector, java.nio.channels.SelectionKey.OP_READ).attach(s);
                }
                else if (s.server != null) {
                    s.serverChannel.register
                        (selector, java.nio.channels.SelectionKey.OP_ACCEPT).attach(s);
                }
            }
            for (s in write) {
                if (s.clientChannel != null) {
                    s.clientChannel.register
                        (selector, java.nio.channels.SelectionKey.OP_WRITE).attach(s);
                }
            }
            var ret : Int;
            
            if (timeout == null) {
                ret = untyped __java__('selector.select(0)');
            }
            else {
                var ms = Std.int(timeout * 1000);
                if (ms == 0) {
                    ret = selector.selectNow();
                }
                else {
                    ret = untyped __java__('selector.select(ms)');
                }
            }
            var read_ret : Array<Socket> = [ ];
            var write_ret : Array<Socket> = [ ];
            var others_ret : Array<Socket> = [ ];
            if (ret > 0) {
                var keyIterator = selector.selectedKeys().iterator();
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
            selector.close();
            return { read : read_ret, write : write_ret, others : others_ret };
        }
        catch (e : Dynamic) {
            try {
                selector.close();
            }
            catch (e : Dynamic) {
                throw e;
            }
            throw e;
        }
	}

    public static function fast_select(read : Array<Socket>,
                                       write : Array<Socket>,
                                       others : Array<Socket>,
                                       ?timeout : Float) : Void
    {
        // Compatible, but not fast
        var ret = select(read, write, others, timeout);
        if (read != null) {
            read.splice(0, read.length);
            while (ret.read.length > 0) {
                read.push(ret.read.pop());
            }
        }
        if (write != null) {
            write.splice(0, write.length);
            while (ret.write.length > 0) {
                write.push(ret.write.pop());
            }
        }
        if (others != null) {
            others.splice(0, others.length);
            while (ret.others.length > 0) {
                others.push(ret.others.pop());
            }
        }
    }
}


class SocketInput extends haxe.io.Input
{
	var channel : java.nio.channels.SocketChannel;
    var blocking : Bool;
    var singleByte : haxe.io.Bytes;

	public function new(channel)
	{
		this.channel = channel;
        this.blocking = true;
        this.singleByte = haxe.io.Bytes.alloc(1);
	}

    public function setBlocking(b : Bool)
    {
        this.blocking = b;
    }

	override public function readByte() : Int
	{
        // "Blocking" read even on non-blocking socket
        while (true) {
            var amt_read = this.readBytes(this.singleByte, 0, 1);
            if (amt_read > 0) {
                return this.singleByte.get(0);
            }
            try {
                var selector = java.nio.channels.Selector.open();
                this.channel.register
                    (selector, java.nio.channels.SelectionKey.OP_READ);
                selector.select();
                selector.close();
            }
            catch (e : IOException) {
                throw haxe.io.Error.Custom(e);
            }
        }
	}

	override public function readBytes(s : Bytes, pos : Int, len : Int) : Int
	{
        var ret = 0;
        try {
            if (this.blocking) {
                var is = this.channel.socket().getInputStream();
                var available = is.available();
                if (available == 0) {
                    return 0;
                }
                if (available < len) {
                    len = available;
                }
                var data = s.getData();
                var byteArray = untyped data;
                ret = this.channel.socket().getInputStream().read
                    (data, pos, len);
            }
            else {
                var data = s.getData();
                var byteArray = untyped data;
                var byteBuffer = java.nio.ByteBuffer.wrap(byteArray, pos, len);
                ret = this.channel.read(byteBuffer);
            }
        }
        catch (e : EOFException) {
            throw new Eof();
        }
        catch (e : IOException) {
            throw haxe.io.Error.Custom(e);
        }
        if (ret == -1) {
            throw new Eof();
        }
        return ret;
	}

	override public function close() : Void
	{
		try {
            this.channel.close();
            this.channel = null;
		}
		catch (e : IOException) {
			throw haxe.io.Error.Custom(e);
		}
	}
}


class SocketOutput extends haxe.io.Output
{
	var channel : java.nio.channels.SocketChannel;
    var blocking : Bool;
    var singleByte : haxe.io.Bytes;

	public function new(channel)
	{
		this.channel = channel;
        this.blocking = true;
        this.singleByte = haxe.io.Bytes.alloc(1);
	}

    public function setBlocking(b : Bool)
    {
        this.blocking = b;
    }

    override public function writeBytes(s : Bytes, pos : Int, len : Int) : Int
    {
        var ret = 0;
        try {
            if (this.blocking) {
                var os = this.channel.socket().getOutputStream();
                var data = s.getData();
                var byteArray = untyped data;
                os.write(data, pos, len);
                os.flush();
                ret = len;
            }
            else {
                var data = s.getData();
                var byteArray = untyped data;
                var byteBuffer = java.nio.ByteBuffer.wrap(byteArray, pos, len);
                ret = this.channel.write(byteBuffer);
            }
        }
		catch (e : EOFException) {
			throw new Eof();
		}
		catch (e : IOException) {
			throw haxe.io.Error.Custom(e);
		}
        return ret;
    }

	override public function writeByte(c : Int)
	{
        this.singleByte.set(0, c);

        // "Blocking" write even on non-blocking socket
        while (true) {
            var amt_written = this.writeBytes(this.singleByte, 0, 1);
            if (amt_written > 0) {
                break;
            }
            try {
                var selector = java.nio.channels.Selector.open();
                this.channel.register
                    (selector, java.nio.channels.SelectionKey.OP_WRITE);
                selector.select();
                selector.close();
            }
            catch (e : IOException) {
                throw haxe.io.Error.Custom(e);
            }
        }
	}

	override public function close() : Void
	{
		try {
            this.channel.close();
            this.channel = null;
		}
		catch (e : IOException) {
			throw haxe.io.Error.Custom(e);
		}
	}

	override public function flush() : Void
	{
		try {
			this.channel.socket().getOutputStream().flush();
		}
        catch (e : java.nio.channels.IllegalBlockingModeException) {
            // Couldn't flush, oh well
        }
		catch (e : IOException) {
			throw haxe.io.Error.Custom(e);
		}
	}
}
