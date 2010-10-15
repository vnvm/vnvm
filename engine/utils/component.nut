class Component
{
	childComponents = null;
	enabled = false;
	
	function addChildComponent(component)
	{
		if (this.childComponents == null) this.childComponents = [];
		this.childComponents.push(component);
	}

	function update(elapsed_time)
	{
		if (this.childComponents != null) {
			foreach (component in this.childComponents) {
				component.update(elapsed_time);
			}
		}
	}
	
	function ended()
	{
		if (this.childComponents != null) {
			foreach (component in this.childComponents) {
				if (!component.ended()) return false;
			}
		}
		return true;
	}

	function drawTo(destinationBitmap)
	{
		if (this.childComponents != null) {
			foreach (component in this.childComponents) {
				component.drawTo(destinationBitmap);
			}
		}
	}
}