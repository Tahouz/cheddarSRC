Compute cache access profiles (sets of UCBs/ECBs)

#Input
- A task sets with control flow graphs

#Output
- Computed cache access profiles for all tasks

#Expected Output
- Computed cache access profiles for all tasks in the previous working examples

#How a cache access profile is computed
A cache access profiles (CAP) of a given task is computed by taking into account its control flow graph (CFG)
A CFG provide the set of basic blocks with their memory addresses.

If a CFG is NOT relocatable, the addresses of basic blocks are absolute addresses. 
If a CFG is relocatable, the addresses of basic blocks are relative address to the memory offset value of the CFG.
For a given basic block, its address is computed by: 
	instruction_address = memory_offset + instruction_offset
	data_address = memeory_offset + data_offset (please note that data cache analysis is not support in Cheddar yet)






