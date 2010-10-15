class RESMAN
{
	resources = null;
	//resources_neverdelete_test = null;
	memory_size_max = 64 * 1024 * 1024;
	//memory_size_max = 8 * 1024 * 1024;
	memory_size_cur = 0;
	
	constructor()
	{
		resources = {};
		//resources_neverdelete_test = {};
	}
	
	function table_to_array(table)
	{
		local array = [];
		foreach (e in table) array.push(e);
		return array;
	}
	
	function gc()
	{
		if (memory_size_cur >= memory_size_max) {
			foreach (resource in resources) {
				if (resource.can_release) resource.use_count /= 2;
			}
			local table = table_to_array(resources);
			table.sort(function(l, r) {
				return r.use_count - l.use_count;
			});
			while (memory_size_cur >= memory_size_max) {
				local resource = table.pop();
				if (resource.can_release) {
					printf("RESMAN.releasing('%s')...", resource.index_name);
					resources.rawdelete(resource.index_name);
					memory_size_cur -= resource.size;
					printf("\n");
				}
			}
		}
		//print();
	}
	
	function getMaxUseCount() {
		local maxUseCount = null;
		foreach (resource in resources) {
			if ((maxUseCount == null) || (maxUseCount < resource.use_count)) {
				maxUseCount = resource.use_count;
			}
		}
		if (maxUseCount == null) maxUseCount = 0;
		return maxUseCount;
	}
	
	function print()
	{
		printf("RESMAN (%d/%d):\n", memory_size_cur, memory_size_max);
		printf("  resources:\n");
		foreach (resource in resources) {
			printf("    - '%s':%s:%d:\n", resource.index_name, resource.can_release ? resource.use_count.tostring() : "locked", resource.size);
		}
	}
	
	function get_resource(name, type, callback, can_release = 1)
	{
		name = name.toupper();
		local type = "WIP";
		local index_name = name + "." + type;
		if (!(index_name in resources)) {
			printf("RESMAN.Loading '%s'...", name);
			local data = callback(name);
			local size = data.memory_size;
			printf("loaded\n");
			// printf("SIZE: %d\n", size);
			resources[index_name] <- {
				name        = name,
				type        = type,
				index_name  = index_name,
				data        = data,
				can_release = 0,
				use_count   = getMaxUseCount() + 1,
				size        = size,
			};
			memory_size_cur += resources[index_name].size;
			gc();
		}
		resources[index_name].can_release = can_release;
		if (can_release) {
			resources[index_name].use_count++;
		}
		return resources[index_name].data;
	}

	function get_image(name, can_release = 1)
	{
		return get_resource(name, "WIP", function(name) {
			return WIP_MSK(arc.get(name + ".WIP", 1), arc.get(name + ".MSK", 0));
		}, can_release);
	}

	function get_mask(name, can_release = 1)
	{
		return get_resource(name, "MSK", function(name) {
			return WIP(arc.get(name + ".MSK", 0));
		}, can_release);
	}
	
	function get_sound(name, can_release = 1)
	{
		//return Sound.fromStream(::arc[name]);
		local result = get_resource(name, "OGG", function(name) {
			return Sound.fromStream(::arc[name]);
		}, can_release);
		//resources_neverdelete_test[name + ".OGG"] <- result;
		return result;
	}
}
