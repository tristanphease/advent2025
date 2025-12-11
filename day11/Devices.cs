public class Devices
{
    // each device is a list of indexes it outputs to
    public required List<Device> devices { get; set; }

    public Devices()
    {
    }

    private int getStartingPoint()
    {
        return devices.Index().Where(x => x.Item.isInput).First().Index;
    }

    private int getServerPoint()
    {
        return devices.Index().Where(x => x.Item.isServer).First().Index;
    }

    private int getDACPoint()
    {
        return devices.Index().Where(x => x.Item.isDAC).First().Index;
    }

    private int getFFTPoint()
    {
        return devices.Index().Where(x => x.Item.isFFT).First().Index;
    }

    public int getNumPathsFromStartToEnd()
    {
        return getNumPathsToOutput(getStartingPoint());
    }

    private int getNumPathsToOutput(int fromPoint)
    {
        // simple search
        // assuming no infinite loops
        int pathCount = 0;
        var stack = new Stack<int>();
        stack.Push(fromPoint);

        while (stack.Count() > 0)
        {
            var currentDevice = devices[stack.Pop()];
            if (currentDevice.isOutput)
            {
                pathCount += 1;
            }
            foreach (var output in currentDevice.outputIndexes)
            {
                stack.Push(output);
            }
        }

        return pathCount;
    }

    private int getNumPaths(int fromPoint, int toPoint)
    {
        int pathCount = 0;
        var stack = new Stack<int>();
        stack.Push(fromPoint);

        while (stack.Count() > 0)
        {
            var currentIndex = stack.Pop();
            var currentDevice = devices[currentIndex];
            if (currentIndex == toPoint)
            {
                pathCount += 1;
            }
            else
            {
                foreach (var output in currentDevice.outputIndexes)
                {
                    stack.Push(output);
                }
            }
        }

        return pathCount;
    }

    public long getNumServerPaths()
    {
        var deviceMemoization = new Dictionary<int, DeviceInfo>();
        var serverIndex = getServerPoint();

        var deviceInfo = GetDeviceInfo(serverIndex, deviceMemoization);

        return deviceInfo.pathsWithDacAndFft;
    }

    private DeviceInfo GetDeviceInfo(int index, Dictionary<int, DeviceInfo> deviceMemoization)
    {
        var device = devices[index];
        if (device.isOutput)
        {
            var deviceInfo = new DeviceInfo()
            {
                pathsToOutput = 1,
                pathsWithDac = 0,
                pathsWithDacAndFft = 0,
                pathsWithFft = 0
            };
            deviceMemoization[index] = deviceInfo;
            return deviceInfo;
        }
        long totalPathsToOutput = 0;
        long totalPathsWithDac = 0;
        long totalPathsWithFft = 0;
        long totalPathsWithDacAndFft = 0;
        foreach (var outputIndex in device.outputIndexes)
        {
            DeviceInfo deviceInfo;
            if (deviceMemoization.ContainsKey(outputIndex))
            {
                deviceInfo = deviceMemoization[outputIndex];
            }
            else
            {
                deviceInfo = GetDeviceInfo(outputIndex, deviceMemoization);
            }
            totalPathsToOutput += deviceInfo.pathsToOutput;
            totalPathsWithDac += deviceInfo.pathsWithDac;
            totalPathsWithFft += deviceInfo.pathsWithFft;
            totalPathsWithDacAndFft += deviceInfo.pathsWithDacAndFft;
        }
        if (device.isDAC)
        {
            totalPathsWithDac = totalPathsToOutput;
            totalPathsWithDacAndFft = totalPathsWithFft;
        }
        if (device.isFFT)
        {
            totalPathsWithFft = totalPathsToOutput;
            totalPathsWithDacAndFft = totalPathsWithDac;
        }
        var totalDeviceInfo = new DeviceInfo()
        {
            pathsToOutput = totalPathsToOutput,
            pathsWithDac = totalPathsWithDac,
            pathsWithFft = totalPathsWithFft,
            pathsWithDacAndFft = totalPathsWithDacAndFft,
        };
        deviceMemoization[index] = totalDeviceInfo;
        return totalDeviceInfo;
    }

    public int getNumServerPathsNaive()
    {
        // simple search
        // assuming no infinite loops
        int pathCount = 0;
        var stack = new Stack<ServerPath>();
        stack.Push(new ServerPath(getServerPoint()));

        while (stack.Count() > 0)
        {
            var currentPath = stack.Pop();
            Console.WriteLine(currentPath);
            var newHashSet = new HashSet<int>(currentPath.visitedIndexes);
            newHashSet.Add(currentPath.currentIndex);
            var currentDevice = devices[currentPath.currentIndex];
            if (currentDevice.isOutput)
            {
                if (currentPath.visitedDAC && currentPath.visitedFFT)
                {
                    pathCount += 1;
                }
            }
            if (currentDevice.isDAC)
            {
                currentPath.visitedDAC = true;
            }
            if (currentDevice.isFFT)
            {
                currentPath.visitedFFT = true;
            }
            foreach (var output in currentDevice.outputIndexes)
            {
                if (!newHashSet.Contains(output))
                {
                    var newPath = new ServerPath(output)
                    {
                        visitedDAC = currentPath.visitedDAC,
                        visitedFFT = currentPath.visitedFFT,
                        visitedIndexes = newHashSet,
                    };
                    stack.Push(newPath);
                }
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

class DeviceInfo
{
    public required long pathsToOutput { get; set; }
    public required long pathsWithDac { get; set; }
    public required long pathsWithFft { get; set; }
    public required long pathsWithDacAndFft { get; set; }
}

class ServerPath
{
    public HashSet<int> visitedIndexes { get; set; }
    public int currentIndex { get; set; }
    public bool visitedDAC { get; set; }
    public bool visitedFFT { get; set; }

    public ServerPath(int index)
    {
        currentIndex = index;
        visitedDAC = false;
        visitedFFT = false;
        visitedIndexes = new HashSet<int>();
    }

    public override string ToString()
    {
        return string.Format("visited: [{0}]", string.Join(",", visitedIndexes));
    }
}

public class Device
{
    public required List<int> outputIndexes { get; set; }
    public bool isOutput { get; set; }
    public bool isInput { get; set; }
    public bool isServer { get; set; }
    public bool isFFT { get; set; }
    public bool isDAC { get; set; }

    public override string ToString()
    {
        return string.Format("{0}{1}{2}{3}{4} [{5}]", isInput ? "input" : "",
                isOutput ? "output" : "",
                isServer ? "server" : "",
                isFFT ? "FFT" : "",
                isDAC ? "DAC" : "",
                string.Join(",", outputIndexes));
    }
}
