package engines.ethornell;

/**
 * ...
 * @author soywiz
 */

class Compression 
{


	MNode[] extract_levels(uint[] freqs, ubyte[] levels) {
		assert(freqs.length == levels.length);

		MNode[] cnodes;

		foreach (value, freq; freqs) if (freq > 0) cnodes ~= new MNode(value, freq);
		while (1) {
			cnodes = cnodes.sort;
			int node1 = MNode.findWithoutParent(cnodes, 0);
			if (node1 == -1) break; // No nodes left without parent.
			int node2 = MNode.findWithoutParent(cnodes, node1 + 1);
			if (node2 == -1) break; // No nodes left without parent.
			auto node_l = cnodes[node1];
			auto node_r = cnodes[node2];
			auto node_p = new MNode(-1, node_l.freq + node_r.freq, 1);
			node_p.childs[0] = node_r;
			node_p.childs[1] = node_l;
			node_r.parent = node_l.parent = node_p;
			cnodes ~= node_p;
		}
		cnodes[cnodes.length - 1].propagateLevels();
		//MNode.show(cnodes);

		for (int n = 0; n < levels.length; n++) levels[n] = 0;
		foreach (node; cnodes) if (node.leaf) levels[node.value] = node.level;
		
		auto lnodes = new MNode[freqs.length];
		foreach (node; cnodes) if (node.leaf) lnodes[node.value] = node;
		
		assert(lnodes.length == freqs.length);
		
		return lnodes;
	}

	ubyte[] compress(ubyte[] data, int level = 0) {
		const min_lz_len = 2;
		const max_lz_len = 0x100 + 2;
		const max_lz_pos = 0x1000;
		const min_lz_pos = 2;
		int   max_lz_len2 = max_lz_len;
		int   max_lz_pos2 = max_lz_len;
		
		struct Encode {
			ubyte  bits;
			ushort value;
		}
		Encode encode[0x200];
		
		uint freq[0x200];
		ubyte levels[0x200];
		struct Block {
			short value;
			short pos;
		}
		Block[] blocks;
		
		max_lz_len2 = (max_lz_len * level) / 9;
		max_lz_pos2 = (max_lz_pos * level) / 9;
		
		for (int n = 0; n < data.length;) {
			int pos = 0, len = 0;
			int max_len = min(max_lz_len2, data.length - n);
			if (level > 0) {
				find_variable_match(data[max(0, n - max_lz_pos2)..n + max_len], data[n..n + max_len], pos, len, min_lz_pos);
			}

			// Compress.
			int id = 0;
			if (len >= min_lz_len) {
				int encoded_len = len - min_lz_len;
				blocks ~= Block(id = 0x100 | (encoded_len & 0xFF), pos);
				n += len;
			} else {
				blocks ~= Block(id = 0x000 | (data[n] & 0xFF), 0);
				n++;
			}
			freq[id]++;
		}
		struct RNode {
			ulong v;
			ubyte bits;
			
			static void iterate(RNode[] rnodes, DSC.Node[] nodes, int cnode = 0, int level = 0, ulong val = 0) {
				if (nodes[cnode].has_childs) {
					foreach (k, ccnode; nodes[cnode].childs) iterate(rnodes, nodes, ccnode, level + 1,
						//val | (k << level)
						(val << 1) | k
					);
				} else {
					with (rnodes[nodes[cnode].leaf_value & 0x1FF]) {
						v    = val;
						bits = level;
					}
				}
			}
			
			char[] toString() { return bits ? format(format("%%0%db", bits), v) : ""; }
		}
		RNode[0x200] rnodes;
		DSC.Node[0x400] cnodes;
		extract_levels(freq, levels);
		//auto nodes = extract_levels(freq, levels);
		ubyte[] r;
		
		uint hash_val = 0x000505D3 + rand(), init_hash_val = hash_val;
		
		void ins_int(uint v) {
			r.length = r.length + 4;
			*cast(uint *)(r.ptr + r.length - 4) = v;
		}
		
		r ~= cast(ubyte[])"DSC FORMAT 1.00\0";
		ins_int(hash_val);
		ins_int(data.length);
		ins_int(blocks.length);
		ins_int(0);
		
		foreach (clevel; levels) r ~= clevel + (hash_update(hash_val) & 0xFF);
		DSC.CompressionInit(init_hash_val, r[r.length - 0x200..r.length], cnodes);
		RNode.iterate(rnodes, cnodes);
		
		//writefln("rnodes:"); foreach (k, rnode; rnodes) if (rnode.bits > 0) writefln("  %03X:%s", k, rnode);
		
		// Write bits.
		BitWritter bitw;
		foreach (block; blocks) {
			auto rnode = rnodes[block.value];
			if (block.value & 0x100) {
				//writefln("BLOCK:LZ(%d, %d)", -(block.pos - 2), (block.value & 0xFF) + 2);
			} else {
				//writefln("BLOCK:BYTE(%02X)", block.value & 0xFF);
			}
			bitw.write(rnode.v, rnode.bits);
			if (block.value & 0x100) {
				bitw.write(block.pos, 12);
				//bitw.finish();
			}
		}
		bitw.finish();
		r ~= bitw.data;
		
		return r;
		//writefln(nodes[0]);
		//writefln(levels);
	}

	
}