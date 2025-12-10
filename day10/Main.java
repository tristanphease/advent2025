void main(String[] args) {
    if (args.length > 0) {
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
