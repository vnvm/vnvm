class Animation
{
	from = {};
	to = {};
	updateObject = null;
	timer = null;

	constructor(updateObject = null)
	{
		this.updateObject = updateObject;
		reset(0);
	}
	
	function reset(totalTime = 0)
	{
		this.from = {};
		this.to = {};
		this.timer = TimerComponent(totalTime);
	}
	
	function increment(key, inc = 0)
	{
		try { this.from[key] <- this.updateObject[key]; } catch (e) { }
		try { this.to[key] <- this.from[key] + inc; } catch (e) { }
	}
	
	function ended()
	{
		return this.timer.ended;
	}
	
	function start()
	{
		this.timer.reset();
	}
	
	function update(elapsed_time = 0)
	{
		if (timer.ended) return;
		this.timer.update(elapsed_time);
		foreach (k, v in this.from) {
			try { 
				local f = this.from[k], t = this.to[k];
				local v = ::interpolate(f, t, this.timer.elapsedf);
				//printf("%s(%f) : %f\n", k, this.timer.elapsedf, v);
				updateObject[k] = v;
			} catch (e) {
			}
			//print("Animation::update::" + k + " = " + v + "\n");
		}
	}
}
