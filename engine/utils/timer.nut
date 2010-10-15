class Timer
{
	start   = 0;
	current = 0;
	length  = 0;
	
	constructor(length = 0)
	{
		this.length = length;
		this.reset();
	}
	
	function increment(ms)
	{
		start -= ms;
	}
	
	function reset()
	{
		start   = getCurrent();
		current = start;
	}
	
	function update(elapsed_time)
	{
		current += elapsed_time;
	}
	
	function getCurrent()
	{
		return ::time_ms();
	}
	
	function _get(name)
	{
		//::printf("Timer._get(%s)\n", name);
		switch (name) {
			case "elapsed" : return getCurrent() - this.start;
			case "elapsedf": {
				if (this.length <= 0) return 1.0;
				return (getCurrent() - this.start).tofloat() / this.length.tofloat();
			}
			case "ended"   : {
				local ended = (getCurrent() - this.start) >= this.length;
				//printf("ENDED: %d\n", ended ? 1 : 0);
				return ended;
			}
		}
	}
}

class TimerComponent extends Timer
{
	function getCurrent()
	{
		return current;
	}
}