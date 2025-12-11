
public static class Parser
{
    public static Devices parseInput(string fileName)
    {
        var deviceStrings = new List<(string deviceName, List<string> outputDevices)>();
        foreach (var line in File.ReadAllLines(fileName))
        {
            var deviceSplit = line.Split(':');
            var deviceName = deviceSplit[0].Trim();
            var outputDevices = deviceSplit[1].Split(" ").Select(x => x.Trim())
                .Where(x => x.Length > 0).ToList();

            deviceStrings.Add((deviceName, outputDevices));
        }

        var devices = new List<Device>();
        for (var deviceIndex = 0; deviceIndex < deviceStrings.Count(); deviceIndex++)
        {
            var device = deviceStrings[deviceIndex];
            var deviceIndexes = new List<int>();
            var isInput = device.deviceName == "you";
            var isOutput = false;
            foreach (var outputDevice in device.outputDevices)
            {
                if (outputDevice == "out")
                {
                    isOutput = true;
                }
                else
                {
                    int outputIndex = deviceStrings.FindIndex(x => x.deviceName == outputDevice);
                    deviceIndexes.Add(outputIndex);
                }
            }
            devices.Add(new Device()
            {
                outputIndexes = deviceIndexes,
                isOutput = isOutput,
                isInput = isInput,
            });
        }

        return new Devices()
        {
            devices = devices
        };
    }
}
