import sys

BLANK = 0
BEAM = 1
SPLITTER = 2


def main():
    if len(sys.argv) >= 3 and sys.argv[2] == "2":
        # open file
        f = open(sys.argv[1])
        lines = f.readlines()
        data = convertData(lines)
        splitDataPart2(data)
    elif len(sys.argv) >= 2:
        # open file
        f = open(sys.argv[1])
        lines = f.readlines()
        data = convertData(lines)
        splitData(data)
    else:
        print("Pass through input file")


def convertData(lines):
    data = []
    for line in lines:
        if len(line.strip()) == 0:
            continue
        lineData = []
        for char in line:
            match char:
                case ".":
                    lineData.append(BLANK)
                case "S":
                    lineData.append(BEAM)
                case "^":
                    lineData.append(SPLITTER)
        data.append(lineData)
    return data


def splitData(inputData):
    splits = 0
    for y in range(len(inputData) - 1):
        inputLine = inputData[y]
        for x in range(len(inputLine)):
            if inputLine[x] == BEAM:
                if inputData[y + 1][x] == BLANK:
                    inputData[y + 1][x] = BEAM
                elif inputData[y + 1][x] == SPLITTER:
                    splits += 1
                    if inputData[y + 1][x - 1] == BLANK:
                        inputData[y + 1][x - 1] = BEAM
                    if inputData[y + 1][x + 1] == BLANK:
                        inputData[y + 1][x + 1] = BEAM
    print(f"total splits = {splits}")


def splitDataPart2(inputData):
    lineWaysToReach = [0] * len(inputData[0])
    y = 0
    for x in range(len(inputData[0])):
        if inputData[0][x] == BEAM:
            lineWaysToReach[x] = 1
    while y < len(inputData) - 1:
        y += 1
        newLineWays = lineWaysToReach.copy()
        for x in range(len(inputData[y])):
            if inputData[y][x] == SPLITTER:
                valueIn = lineWaysToReach[x]
                newLineWays[x] = 0
                newLineWays[x - 1] += valueIn
                newLineWays[x + 1] += valueIn
        lineWaysToReach = newLineWays

    totalTimelines = 0
    for x in lineWaysToReach:
        totalTimelines += x
    print(f"Total timelines is {totalTimelines}")


# this works but is too slow to run so have to do in a smarter way
def splitDataPart2Slow(inputData):
    timelineCount = 0
    decisions = [[False], [True]]
    startX = 0
    for x in range(len(inputData[0])):
        if inputData[0][x] == BEAM:
            startX = x
    while len(decisions) > 0:
        decisionsSoFar = decisions.pop()
        y = 0
        x = startX
        decisionIndex = 0
        while True:
            y += 1
            if y >= len(inputData) - 1:
                timelineCount += 1
                break
            if inputData[y][x] == BLANK:
                pass
            elif inputData[y][x] == SPLITTER:
                if decisionIndex >= len(decisionsSoFar):
                    # new decision to be made
                    decisionIndex += 1
                    if x > 0 and inputData[y][x - 1] == BLANK:
                        if x < len(inputData[y]) - 1 and inputData[y][x + 1] == BLANK:
                            newDecisions = decisionsSoFar.copy()
                            newDecisions.append(True)
                            decisions.append(newDecisions)
                        decisionsSoFar.append(False)
                        x -= 1
                    elif x < len(inputData[y]) - 1 and inputData[y][x + 1] == BLANK:
                        decisionsSoFar.append(True)
                        x += 1
                else:
                    # use existing decision
                    decision = decisionsSoFar[decisionIndex]
                    decisionIndex += 1
                    if decision:
                        x += 1
                    else:
                        x -= 1
    print(f"total timelines is {timelineCount}")


main()
