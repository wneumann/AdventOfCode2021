import ArgumentParser
import Foundation

// MARK: - Command line parsing
struct RunOptions: ParsableArguments {
  @Argument(help: "The location of the input file.", transform: URL.init(fileURLWithPath:))
  var inURL: URL
}

let options = RunOptions.parseOrExit()

// MARK: - Actual work done here
func countIncreasesIn(_ slice: ArraySlice<Int>) -> Int {
  zip(slice.dropFirst(), slice).filter { $0 > $1 }.count
}

let input = try String(contentsOf: options.inURL, encoding: .utf8)
var readings = input.components(separatedBy: .newlines).compactMap(Int.init)[...]

print("There are \(countIncreasesIn(readings)) increases in depth measurements.")

var windowed = [Int]()
while readings.count >= 3 {
  windowed.append(readings.prefix(3).reduce(0, +))
  readings.removeFirst()
}

print("There are \(countIncreasesIn(windowed[...])) increases in windowed depth measurements.")
