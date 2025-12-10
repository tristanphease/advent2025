import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;

public class Parser {

    public static ArrayList<Machine> parseFile(String fileName) {
        try {
            FileReader fileReader = new FileReader(fileName);
            var lines = fileReader.readAllLines();
            var machines = new ArrayList<Machine>();
            for (var line : lines) {
                if (line.trim().length() > 0) {
                    machines.add(parseLine(line));
                }
            }
            fileReader.close();
            return machines;
        } catch (FileNotFoundException ex) {
            IO.println("Couldn't find file: " + fileName);
        } catch (IOException ex) {
            IO.println("IO error: " + ex.toString());
        }
        return null;
    }

    private static Machine parseLine(String line) {
        var startIndicators = line.indexOf('[');
        var endIndicators = line.indexOf(']');
        var indicatorsString = line.substring(
            startIndicators + 1,
            endIndicators
        );
        var indicators = new ArrayList<Boolean>();
        for (int i = 0; i < indicatorsString.length(); i++) {
            if (indicatorsString.charAt(i) == '#') {
                indicators.add(true);
            } else {
                indicators.add(false);
            }
        }

        var startJoltages = line.indexOf('{');
        var endJoltages = line.indexOf('}');
        var joltagesString = line.substring(startJoltages + 1, endJoltages);
        var joltages = new ArrayList<Integer>();
        for (var joltageString : joltagesString.split(",")) {
            joltages.add(Integer.parseInt(joltageString));
        }

        var startButtons = endIndicators + 1;
        var endButtons = startJoltages;
        var buttonsString = line.substring(startButtons, endButtons);

        var buttonWirings = new ArrayList<ButtonWiring>();
        for (var buttonString : buttonsString.split(" ")) {
            buttonString = buttonString.trim();
            if (buttonString.length() > 0) {
                // chop off parentheses
                buttonString = buttonString.substring(
                    1,
                    buttonString.length() - 1
                );
                var wirings = new ArrayList<Integer>();
                for (var button : buttonString.split(",")) {
                    wirings.add(Integer.parseInt(button));
                }
                buttonWirings.add(new ButtonWiring(wirings));
            }
        }

        return new Machine(indicators, buttonWirings, joltages);
    }
}
