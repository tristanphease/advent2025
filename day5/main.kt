import java.io.File

fun main(args: Array<String>) {
    if (args.size > 0) {
        val ingredientInfos = readInput(args[0])
        val freshAvailableIngredients = getFreshIngredients(ingredientInfos)
        println("Num of available fresh ingredients = " + freshAvailableIngredients.size.toString())
    } else {
        println("Pass through input file as an argument")
    }
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
