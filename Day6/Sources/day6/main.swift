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
let tank = input.split(separator: ",").compactMap { Int($0) }

func fishies(_ x: Int, _ days: Int = 80) -> Int {
  var fish = Array(repeating: 0, count: 9)
  fish[x] = 1
  for _ in 0..<days {
    let freshFish = fish[0]
    fish = Array(fish.dropFirst()) + [freshFish]
    fish[6] += freshFish
  }
  return fish.reduce(0, +)
}

func fishAfter(days: Int) -> Int {
  let spawns =  (1...6).map{ fishies($0, days) }
  return tank.map { spawns[$0 - 1] }.reduce(0, +)
}

print("*  There are a total of \(fishAfter(days: 80)) laternfish after 80 days")
print("** There are a total of \(fishAfter(days: 256)) laternfish after 256 days")
