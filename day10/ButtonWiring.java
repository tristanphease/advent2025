import java.util.ArrayList;

public class ButtonWiring {

    public ArrayList<Integer> wiring;

    public ButtonWiring(ArrayList<Integer> wiring) {
        this.wiring = wiring;
    }

    @Override
    public String toString() {
        StringBuilder wiringString = new StringBuilder();
        for (int i = 0; i < wiring.size(); i++) {
            wiringString.append(wiring.get(i));
            if (i < wiring.size() - 1) {
                wiringString.append(',');
            }
        }
        return "(" + wiringString.toString() + ")";
    }
}
