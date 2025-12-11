
class Program
{
    static void Main(string[] args)
    {
        if (args.Length > 1 && args[1] == "2")
        {
            var devices = Parser.parseInput(args[0]);
            // Console.WriteLine(devices);
            var numPaths = devices.getNumServerPaths();

            // devices.getNumServerPaths2();
            Console.WriteLine("Number of server paths is {0}", numPaths);
        }
        else if (args.Length > 0)
        {
            var devices = Parser.parseInput(args[0]);
            // Console.WriteLine(devices);
            var numPaths = devices.getNumPathsFromStartToEnd();

            Console.WriteLine("Number of paths is {0}", numPaths);
        }
        else
        {
            Console.WriteLine("Pass through input file to start");
        }
    }
}
