package java.vm;

@:native('haxe.java.vm.Mutex') class Mutex
{
	@:private var owner:java.lang.Thread;
	@:private var lockCount:Int = 0;

	/**
		Creates a mutex, which can be used to acquire a temporary lock to access some resource.
		The main difference with a lock is that a mutex must always be released by the owner thread
	**/
	public function new()
	{

	}

	/**
		Try to acquire the mutex, returns true if acquire or false if it's already locked by another thread.
	**/
	public function tryAcquire():Bool
	{
		var ret = false, cur = java.lang.Thread.currentThread();
		untyped __lock__(this, {
			var expr = null;
			if (owner == null)
			{
				ret = true;
				if(lockCount != 0) throw "assert";
				lockCount = 1;
				owner = cur;
			} else if (owner == cur) {
				ret = true;
				owner = cur;
				lockCount++;
			}
		});
		return ret;
	}

	/**
		The current thread acquire the mutex or wait if not available.
		The same thread can acquire several times the same mutex, but must release it as many times it has been acquired.
	**/
	public function acquire():Void
	{
		var cur = java.lang.Thread.currentThread();
		untyped __lock__(this, {
			var expr = null;
			if (owner == null)
			{
				owner = cur;
				if (lockCount != 0) throw "assert";
				lockCount = 1;
			} else if (owner == cur) {
				lockCount++;
			} else {
				var acquired : Bool = false;
				// Loop until we are able to acquire the lock. This is not busy waiting
				// and most of the time the while loop will exit after the first iteration.
				// The scenario in which it is necessary to keep calling wait. 
				// 1) Mutex is not owned. 2) Thread A comes along and calls acquire and sets current
 				// owner to itself. 3) Thread B comes along and calls acquire but mutex is already owned.
				// 4) Next it checks to see if it is itself that owns it but it isn't. 5) Next it calls
				// wait(). 6) Thread A now calls release and hence notify(). However, notify is asynchronous
				// does not result in immediate release of thread B wait(). 7) Thread A or some other thread calls
				// acquire again and since owner == null, it's able to claim ownership. 9) Thread B wait() finally
				// releases based on thread A previous notify(). 10) Thead B claims ownership and sets lockCount = 1.
				// Result is that thread A thinks it owns the Mutex but thread B has hijacked it. Both threads think they
				// own it and both will try to release it. All kinds of bad stuff happens. 
				// Solution is to check that owner is still null when release from wait(). If not, we wait again. The wait()
				// will be released because the thread that snuck in and grabbed the lock will call notify() providing another
				// chance for thread B to actually get the lock. 
				while (!acquired)
				{
					try { untyped this.wait(); } catch(e:Dynamic) { throw e; }
					acquired = (owner == null);
				}
				lockCount = 1;
				owner = cur;
			}
		});
	}

	/**
		Release a mutex that has been acquired by the current thread. If the current thread does not own the mutex, an exception will be thrown
	**/
	public function release():Void
	{
		var cur = java.lang.Thread.currentThread();
		untyped __lock__(this, {
			var expr = null;
			if (owner != cur) {
				throw "This mutex isn't owned by the current thread!";
			}
			if (--lockCount == 0)
			{
				this.owner = null;
				untyped this.notify();
			}
		});
	}
}
