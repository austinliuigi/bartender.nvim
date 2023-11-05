local partition = {}


--- Separator that evenly spaces out sections, i.e. all partitions in a bar are the same length
--
function partition.provider()
  return {
    components = {
      { "%=" },
    }
  }
end


return partition
