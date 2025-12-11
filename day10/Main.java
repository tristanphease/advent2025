void main(String[] args) {
    if (args.length > 0 && args[0].equals("test")) {
        // doing this properly is too much of a pain
        Util.runTests();
    } else if (args.length > 1 && args[1].equals("2")) {
        String inputFile = args[0];
        var machines = Parser.parseFile(inputFile);
        int sumFewestJoltageButtonPresses = 0;
        for (var machine : machines) {
            int fewestPresses = machine.getFewestPressesToConfigureJoltage();
            sumFewestJoltageButtonPresses += fewestPresses;
        }
        IO.println(
            "Total fewest button presses for joltage = " +
                sumFewestJoltageButtonPresses
        );
    } else if (args.length > 0) {
        String inputFile = args[0];
        var machines = Parser.parseFile(inputFile);
        int sumFewestButtonPresses = 0;
        for (var machine : machines) {
            int fewestPresses = machine.getFewestPressesToConfigure();
            sumFewestButtonPresses += fewestPresses;
        }
        IO.println("Total fewest button presses = " + sumFewestButtonPresses);
    } else {
        IO.println("Pass through input file into args");
    }
}
