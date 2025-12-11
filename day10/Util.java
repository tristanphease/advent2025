import java.util.ArrayList;

class Util {

    public static ArrayList<ArrayList<Integer>> partitions(int total, int num) {
        var partitions = new ArrayList<ArrayList<Integer>>();
        if (total == 0 || num == 1) {
            var onlyTotal = new ArrayList<Integer>();
            for (int i = 0; i < num; i++) {
                onlyTotal.add(total);
            }
            partitions.add(onlyTotal);
            return partitions;
        }
        for (int currentValue = total; currentValue >= 0; currentValue--) {
            var smallerPartitions = partitions(total - currentValue, num - 1);
            for (var smallPartition : smallerPartitions) {
                smallPartition.add(currentValue);
            }
            partitions.addAll(smallerPartitions);
        }
        return partitions;
    }

    public static ArrayList<Integer> emptyList(int size) {
        var list = new ArrayList<Integer>(size);
        for (int i = 0; i < size; i++) {
            list.add(0);
        }
        return list;
    }

    public static void runTests() {
        var partitions1 = partitions(4, 2);
        IO.println(partitions1);
        assert partitions1.size() == 5;
        var partitions2 = partitions(4, 3);
        IO.println(partitions2);
        assert partitions2.size() == 15;
    }
}
