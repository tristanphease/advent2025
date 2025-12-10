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
}

record PressInfo(
    ArrayList<Boolean> indicatorState,
    ArrayList<Integer> buttonPressList
) {}
