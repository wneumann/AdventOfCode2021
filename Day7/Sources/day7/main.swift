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
var counts = [Int:Int]()
input.split(separator: ",").compactMap { Int($0) }.forEach { counts[$0, default: 0] += 1 }
let maxpos = counts.keys.max()!


func computeCosts(for counts: [Int: Int], using costFunc: (Int) -> (Int, Dictionary<Int, Int>.Element) -> Int) -> [Int] {
  var lessThan = [(Int, Int)]()
  var equalTo: Int? = counts[0, default: 0]
  var greaterThan = counts
  greaterThan.removeValue(forKey: 0)
  var costs = [counts.reduce(0, costFunc(0))]

  for pos in 1...maxpos {
    if let eq = equalTo {
      lessThan.append((pos - 1, eq))
    }
    equalTo = counts[pos]
    greaterThan.removeValue(forKey: pos)
    
    let lessCosts = lessThan.reduce(0, costFunc(pos))
    let greaterCosts = greaterThan.reduce(0, costFunc(pos))
    costs.append(lessCosts + greaterCosts)
  }

  return costs
}


// MARK: - Part 1

let costs = computeCosts(for: counts, using: { pos in { sum, val in sum + (abs(val.key - pos) * val.value) } })
print("*  Minimal feul cost: \(costs.min()!)")

// MARK: - Part 2

let costs2 = computeCosts(for: counts, using: { pos in { sum, val in
  let d = abs(val.key - pos), c = (d * (d + 1)) / 2
  return sum + (c * val.value) } })
print("** Minimal feul cost: \(costs2.min()!)")
