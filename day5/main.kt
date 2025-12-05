import java.io.File

fun main(args: Array<String>) {
    if (args.size > 1 && args[1].equals("2")) {
        val ingredientInfos = readInput(args[0])
        val freshIngredientNum = getFreshIngredientNum(ingredientInfos)
        println("Num of all fresh ingredients = " + freshIngredientNum)
    } else if (args.size > 0) {
        val ingredientInfos = readInput(args[0])
        val freshAvailableIngredients = getFreshIngredients(ingredientInfos)
        println("Num of available fresh ingredients = " + freshAvailableIngredients.size.toString())
    } else {
        println("Pass through input file as an argument")
    }
}

fun getFreshIngredientNum(ingredientInfo: IngredientInfo): Long {
    var freshIngredientNum = 0
    // need to generate a list of non-overlapping ranges
    // so that we can just sum them up
    var coveredRanges = ArrayList<FreshRange>()
    var rangesToCover = ArrayDeque(ingredientInfo.freshRanges)
    loop@ while (!rangesToCover.isEmpty()) {
        var topRange = rangesToCover.removeFirst()
        for (coveredRange in coveredRanges) {
            if (coveredRange.start <= topRange.start && coveredRange.end >= topRange.end) {
                // top range is completely covered by an existing range, don't need top range at all
                // println("Range $topRange covered by $coveredRange")
                continue@loop
            } else if (coveredRange.start > topRange.start && coveredRange.end < topRange.end) {
                // covered is inside top range, need to split top range and check again later
                val firstRange = FreshRange(topRange.start, coveredRange.start - 1)
                val secondRange = FreshRange(coveredRange.end + 1, topRange.end)
                // println("Split range $topRange into $firstRange and $secondRange from range $coveredRange")
                rangesToCover.add(firstRange)
                rangesToCover.add(secondRange)
                continue@loop
            } else if (coveredRange.start <= topRange.start && coveredRange.end <= topRange.end && coveredRange.end >= topRange.start) {
                // covered overlaps with the start of top range, just modify top range and continue
                // println("Range $topRange shortened by $coveredRange - cut off bottom")
                topRange = FreshRange(coveredRange.end + 1, topRange.end)
            } else if (coveredRange.start >= topRange.start && coveredRange.end >= topRange.end && coveredRange.start <= topRange.end) {
                // covered overlaps with the end of top range, modify and continue
                // println("Range $topRange shortened by $coveredRange - cut off top")
                topRange = FreshRange(topRange.start, coveredRange.start - 1)
            }
        }
        coveredRanges.add(topRange)
    }
    // println("All covered ranges:")

    var totalIngredients = 0L
    for (range in coveredRanges) {
        // println(range)
        totalIngredients += range.end - range.start + 1
    }
    return totalIngredients
}

fun getFreshIngredients(ingredientInfo: IngredientInfo): List<Long> {
    var freshIngredients = ArrayList<Long>()
    for (available in ingredientInfo.availableIngredients) {
        for (range in ingredientInfo.freshRanges) {
            if (available >= range.start && available <= range.end) {
                freshIngredients.add(available)
                break
            }
        }
    }
    return freshIngredients
}

data class FreshRange(val start: Long, val end: Long)

data class IngredientInfo(val freshRanges: List<FreshRange>, val availableIngredients: List<Long>)

fun readInput(fileName: String): IngredientInfo {
    val fileLines = File(fileName)
        .readLines()

    var freshRanges = ArrayList<FreshRange>()
    var availableIngredients = ArrayList<Long>()
    var ranges = true
    for (line in fileLines) {
        if (line.isEmpty()) {
            ranges = false
        } else if (ranges) {
            freshRanges.add(parseFreshRange(line))
        } else {
            availableIngredients.add(line.toLong())
        }
    }

    return IngredientInfo(freshRanges, availableIngredients)
}

fun parseFreshRange(input: String): FreshRange {
    val inputVals = input.split("-")
    return FreshRange(inputVals[0].toLong(), inputVals[1].toLong())
}
