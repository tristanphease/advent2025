import java.util.ArrayDeque;
import java.util.ArrayList;

public class Machine {

    private ArrayList<Boolean> indicators;
    private ArrayList<ButtonWiring> buttonWirings;
    private ArrayList<Integer> joltageRequirements;

    public Machine(
        ArrayList<Boolean> indicators,
        ArrayList<ButtonWiring> buttonWirings,
        ArrayList<Integer> joltageRequirements
    ) {
        this.indicators = indicators;
        this.buttonWirings = buttonWirings;
        this.joltageRequirements = joltageRequirements;
    }

    public Integer getFewestPressesToConfigure() {
        // edge case - don't think input data has this but will add for completeness
        // when target is all false, just return 0
        if (indicators.stream().allMatch(x -> !x)) {
            return 0;
        }

        // setup indicators first
        var currentIndicators = new ArrayList<Boolean>();
        for (int i = 0; i < this.indicators.size(); i++) {
            currentIndicators.add(false);
        }

        // general strategy:
        // do breadth first search
        // if any toggle would get to correct indicator state, do that
        var queue = new ArrayDeque<PressInfo>();
        queue.add(new PressInfo(currentIndicators, new ArrayList<>()));

        while (!queue.isEmpty()) {
            var oldest = queue.remove();
            for (var i = 0; i < this.buttonWirings.size(); i++) {
                var buttonWiring = this.buttonWirings.get(i);
                var newIndicators = this.indicatorWithChange(
                    oldest.indicatorState(),
                    buttonWiring.wiring
                );
                if (this.indicatorsEqual(this.indicators, newIndicators)) {
                    return oldest.buttonPressList().size() + 1;
                }
                var newPressList = new ArrayList<>(oldest.buttonPressList());
                newPressList.add(i);
                queue.add(new PressInfo(newIndicators, newPressList));
            }
        }
        throw new RuntimeException("Unreachable");
    }

    private ArrayList<Boolean> indicatorWithChange(
        ArrayList<Boolean> indicators,
        ArrayList<Integer> wiring
    ) {
        var newIndicators = new ArrayList<Boolean>(indicators);
        for (var indicatorIndex : wiring) {
            newIndicators.set(
                indicatorIndex,
                !newIndicators.get(indicatorIndex)
            );
        }
        return newIndicators;
    }

    private boolean indicatorsEqual(
        ArrayList<Boolean> indicators1,
        ArrayList<Boolean> indicators2
    ) {
        // assume sizes are the same
        for (int i = 0; i < indicators1.size(); i++) {
            if (indicators1.get(i) != indicators2.get(i)) {
                return false;
            }
        }
        return true;
    }

    public Integer getFewestPressesToConfigureJoltageFast() {
        // edge case - don't think input data has this but will add for completeness
        // when target is all 0, just return 0
        if (joltageRequirements.stream().allMatch(x -> x == 0)) {
            return 0;
        }

        IO.println("checking machine:\n" + this);

        var constraints = new ArrayList<JoltageConstraint>();
        for (int i = 0; i < this.joltageRequirements.size(); i++) {
            var indices = new ArrayList<Integer>();
            final int joltageIndex = i;
            for (var j = 0; j < this.buttonWirings.size(); j++) {
                var wirings = this.buttonWirings.get(j).wiring;
                if (wirings.stream().anyMatch(x -> x == joltageIndex)) {
                    indices.add(j);
                }
            }
            constraints.add(
                new JoltageConstraint(
                    this.joltageRequirements.get(i),
                    indices,
                    i
                )
            );
        }

        this.buttonWirings.sort((x, y) -> {
            // sort descending
            var xSize = x.wiring.size();
            var ySize = y.wiring.size();
            if (xSize < ySize) {
                return 1;
            } else if (xSize > ySize) {
                return -1;
            }
            return 0;
        });
        IO.println("Re-ordered wirings: - " + this.buttonWirings);

        var foundSolution = false;
        var currentMultiples = Util.emptyList(this.buttonWirings.size());
        var currentJoltage = getJoltageFromMultiples(currentMultiples);
        int buttonWiringIndex = 0;
        while (!foundSolution) {
            // add as much as is possible
            var currentButton = this.buttonWirings.get(
                buttonWiringIndex
            ).wiring;
            int minimum = Integer.MAX_VALUE;
            for (int i = 0; i < currentButton.size(); i++) {
                int joltageIndex = currentButton.get(i);
                int joltageLeft =
                    this.joltageRequirements.get(joltageIndex) -
                    currentJoltage.get(joltageIndex);
                if (joltageLeft < minimum) {
                    minimum = joltageLeft;
                }
            }

            currentMultiples.set(
                buttonWiringIndex,
                currentMultiples.get(buttonWiringIndex) + minimum
            );

            currentJoltage = getJoltageFromMultiples(currentMultiples);
            var invalidJoltageAmounts = checkJoltageOverflows(currentJoltage);
            if (!invalidJoltageAmounts.isEmpty()) {
                // need to go back and subtract to fix up
                for (var j = buttonWiringIndex - 1; j >= 0; j--) {
                    ArrayList<Integer> wirings = this.buttonWirings.get(
                        j
                    ).wiring;
                    var overflow = invalidJoltageAmounts
                        .stream()
                        .filter(z -> {
                            return wirings
                                .stream()
                                .anyMatch(y -> {
                                    return y.equals(z.index());
                                });
                        })
                        .findFirst();
                    if (overflow.isPresent()) {
                        currentMultiples.set(
                            j,
                            currentMultiples.get(j) - overflow.get().amount()
                        );
                        currentJoltage = getJoltageFromMultiples(
                            currentMultiples
                        );
                        // need to increment j to undo the for loop so we re-check j
                        j++;
                    }
                }
            } else {
                foundSolution = isValidJoltageMultiplesSolution(currentJoltage);
                buttonWiringIndex++;
                if (
                    buttonWiringIndex == this.buttonWirings.size() &&
                    !foundSolution
                ) {
                    // need to go back and add to get to correct value for values that don't add
                    for (int i = this.buttonWirings.size() - 1; i >= 0; i--) {}
                }
            }

            IO.println("Current multiples: - " + currentMultiples);
            IO.println("Current joltage: - " + currentJoltage);
        }

        int solutionSize = currentMultiples
            .stream()
            .reduce(0, (accum, multiplier) -> {
                return accum + multiplier;
            });

        return solutionSize;
    }

    public Integer getFewestPressesToConfigureJoltage() {
        // edge case - don't think input data has this but will add for completeness
        // when target is all 0, just return 0
        if (joltageRequirements.stream().allMatch(x -> x == 0)) {
            return 0;
        }

        IO.println("checking machine:\n" + this);

        // clever solution would be to form simultaneous equations
        // find all solutions them then get the lowest
        // however gonna do a more hacky solution where we look for all solutions a bit more manually
        // then get the lowest
        var constraints = new ArrayList<JoltageConstraint>();
        for (int i = 0; i < this.joltageRequirements.size(); i++) {
            var indices = new ArrayList<Integer>();
            final int joltageIndex = i;
            for (var j = 0; j < this.buttonWirings.size(); j++) {
                var wirings = this.buttonWirings.get(j).wiring;
                if (wirings.stream().anyMatch(x -> x == joltageIndex)) {
                    indices.add(j);
                }
            }
            constraints.add(
                new JoltageConstraint(
                    this.joltageRequirements.get(i),
                    indices,
                    i
                )
            );
        }
        // the constraint indices have to sum to the total
        var smallestSolution = getSmallestJoltageSolution(constraints);
        if (smallestSolution == Integer.MAX_VALUE) {
            throw new RuntimeException("no solutions found");
        }

        IO.println("found solution - " + smallestSolution);

        return smallestSolution;
    }

    private Integer getSmallestJoltageSolution(
        ArrayList<JoltageConstraint> constraints
    ) {
        // find constraint with fewest indices since they're quicker to search through
        constraints.sort((x, y) -> {
            if (x.indices().size() < y.indices().size()) {
                return -1;
            } else if (x.indices().size() > y.indices().size()) {
                return 1;
            }
            return Integer.compare(x.total(), y.total());
        });

        var multiples = Util.emptyList(this.buttonWirings.size());
        var stack = new ArrayDeque<JoltageInfo>();
        stack.add(new JoltageInfo(multiples, constraints));
        var smallestSolutionSize = Integer.MAX_VALUE;
        while (!stack.isEmpty()) {
            var joltageInfo = stack.pop();
            var newConstraints = new ArrayList<>(joltageInfo.constraints());
            var nextConstraint = newConstraints.remove(0);

            var currentJoltages = getJoltageFromMultiples(
                joltageInfo.multiples()
            );
            int total =
                nextConstraint.total() -
                currentJoltages.get(nextConstraint.joltageIndex());
            var partitions = Util.partitions(
                total,
                nextConstraint.indices().size()
            );
            for (var partition : partitions) {
                var newMultiples = new ArrayList<>(joltageInfo.multiples());
                for (var i = 0; i < partition.size(); i++) {
                    var buttonIndex = nextConstraint.indices().get(i);
                    var partitionMultiple = partition.get(i);
                    newMultiples.set(
                        buttonIndex,
                        newMultiples.get(buttonIndex) + partitionMultiple
                    );
                }
                var joltages = getJoltageFromMultiples(newMultiples);
                // IO.println("testing multiples - " + newMultiples);
                // IO.println("testing joltages - " + joltages);
                int solutionSize = this.getMultipleSize(newMultiples);
                if (
                    this.isValidJoltageMultiples(joltages) &&
                    solutionSize < smallestSolutionSize
                ) {
                    if (this.isValidJoltageMultiplesSolution(joltages)) {
                        // IO.println("valid solution");
                        smallestSolutionSize = solutionSize;
                    } else if (!newConstraints.isEmpty()) {
                        // IO.println("adding to stack");
                        stack.add(
                            new JoltageInfo(newMultiples, newConstraints)
                        );
                    } else {
                        // IO.println("end of the line");
                    }
                }
            }
        }

        return smallestSolutionSize;
    }

    private int getMultipleSize(ArrayList<Integer> multiples) {
        return multiples
            .stream()
            .reduce(0, (accum, multiplier) -> {
                return accum + multiplier;
            });
    }

    private ArrayList<JoltageOverflow> checkJoltageOverflows(
        ArrayList<Integer> joltages
    ) {
        var invalidJoltageAmounts = new ArrayList<JoltageOverflow>();
        for (int i = 0; i < joltages.size(); i++) {
            if (joltages.get(i) > this.joltageRequirements.get(i)) {
                invalidJoltageAmounts.add(
                    new JoltageOverflow(
                        i,
                        joltages.get(i) - this.joltageRequirements.get(i)
                    )
                );
            }
        }
        return invalidJoltageAmounts;
    }

    // check if we've exceeded the joltage requirements
    private boolean isValidJoltageMultiples(ArrayList<Integer> joltages) {
        for (int i = 0; i < joltages.size(); i++) {
            if (joltages.get(i) > this.joltageRequirements.get(i)) {
                return false;
            }
        }
        return true;
    }

    // check if we've got a solution that matches the joltage requirements
    private boolean isValidJoltageMultiplesSolution(
        ArrayList<Integer> joltages
    ) {
        for (int i = 0; i < joltages.size(); i++) {
            if (!joltages.get(i).equals(this.joltageRequirements.get(i))) {
                return false;
            }
        }
        return true;
    }

    private ArrayList<Integer> getJoltageFromMultiples(
        ArrayList<Integer> multiples
    ) {
        var joltages = Util.emptyList(this.joltageRequirements.size());
        for (var i = 0; i < multiples.size(); i++) {
            int multiple = multiples.get(i);
            for (var joltageIndex : this.buttonWirings.get(i).wiring) {
                joltages.set(
                    joltageIndex,
                    joltages.get(joltageIndex) + multiple
                );
            }
        }
        return joltages;
    }

    @Override
    public String toString() {
        return (
            "Indicators: " +
            this.indicators.toString() +
            "\nButton Wiring:" +
            this.buttonWirings.toString() +
            "\nJoltage Requirements: " +
            this.joltageRequirements.toString()
        );
    }
}

record PressInfo(
    ArrayList<Boolean> indicatorState,
    ArrayList<Integer> buttonPressList
) {}

// the indices are into the button wiring
record JoltageConstraint(
    Integer total,
    ArrayList<Integer> indices,
    Integer joltageIndex
) {
    void debugPrint() {
        IO.println("indices: " + indices.toString());
        IO.println("sum to " + total);
    }
}

record JoltageInfo(
    ArrayList<Integer> multiples,
    ArrayList<JoltageConstraint> constraints
) {}

record JoltageOverflow(Integer index, Integer amount) {}
