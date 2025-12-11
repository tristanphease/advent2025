public class Devices
{
    // each device is a list of indexes it outputs to
    public required List<Device> devices { get; set; }

    private IEnumerable<int> getStartingPoints()
    {
        return devices.Index().Where(x => x.Item.isInput).Select(x => x.Index);
    }

    public int getNumPathsFromStartToEnd()
    {
        // simple search
        // assuming no infinite loops
        int pathCount = 0;
        var queue = new Queue<int>();
        foreach (var startIndex in getStartingPoints())
        {
            queue.Enqueue(startIndex);
        }

        while (queue.Count() > 0)
        {
            var currentDevice = devices[queue.Dequeue()];
            if (currentDevice.isOutput)
            {
                pathCount += 1;
            }
            foreach (var output in currentDevice.outputIndexes)
            {
                queue.Enqueue(output);
            }
        }

        return pathCount;
    }

    public override string ToString()
    {
        string output = "[\n";
        foreach (var device in devices)
        {
            output += device.ToString() + "\n";
        }
        output += "]";
        return output;
    }
}

public class Device
{
    public required List<int> outputIndexes { get; set; }
    public bool isOutput { get; set; }
    public bool isInput { get; set; }

    public override string ToString()
    {
        return string.Format("{0}{1} [{2}]", isInput ? "input" : "", isOutput ? "output" : "", string.Join(",", outputIndexes));
    }
}
