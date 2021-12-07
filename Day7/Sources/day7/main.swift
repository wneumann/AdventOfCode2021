import ArgumentParser
import Foundation

// MARK: - Command line parsing
struct RunOptions: ParsableArguments {
  @Argument(help: "The location of the input file.", transform: URL.init(fileURLWithPath:))
  var inURL: URL
}

let options = RunOptions.parseOrExit()

// MARK: - Actual work done here
let input = try String(contentsOf: options.inURL, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
//let positions = input.split(separator: ",").compactMap { Int($0) }
var counts = [Int:Int]()
input.split(separator: ",").compactMap { Int($0) }.forEach { counts[$0, default: 0] += 1 }
let maxpos = counts.keys.max()!


// MARK: - Part 1

var costs = [counts.reduce(0, { partialResult, val in partialResult + (val.key * val.value) })]

var lessThan = 0
var equalTo = counts[0, default: 0]
var greaterThan = counts.filter { $0.value > 0 && $0.key != 0 }.values.reduce(0, +)
for pos in 1...maxpos {
  lessThan += equalTo
  equalTo = counts[pos, default: 0]
  greaterThan -= equalTo
  let lastCost = costs.last!
  let newCost = lastCost + lessThan - equalTo - greaterThan
  costs.append(newCost)
}

print("*  Minimal feul cost: \(costs.min()!)")

// MARK: - Part 2

var costs2 = [counts.reduce(0, { partialResult, val in partialResult + ((val.key * (val.key + 1) / 2) * val.value) })]

var lessThan2 = [(Int, Int)]()
var equalTo2: Int? = counts[0, default: 0]
var greaterThan2 = counts
greaterThan2.removeValue(forKey: 0)

for pos in 1...maxpos {
  if let eq = equalTo2 {
    lessThan2.append((pos - 1, eq))
  }
  equalTo2 = counts[pos]
  greaterThan2.removeValue(forKey: pos)
  
  let lessCosts = lessThan2.reduce(0) { partialResult, lessVal in
    let d = pos - lessVal.0, c = (d * (d + 1)) / 2
    return partialResult + (c * lessVal.1)
  }
  let greaterCosts = greaterThan2.reduce(0) { partialResult, greaterVal in
    let d = greaterVal.0 - pos, c = (d * (d + 1)) / 2
    return partialResult + (c * greaterVal.1)
  }
  costs2.append(lessCosts + greaterCosts)
}

print("** Minimal feul cost: \(costs2.min()!)")
