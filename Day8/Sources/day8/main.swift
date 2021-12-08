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
let chop = input.split(separator: "\n").map { $0.components(separatedBy: " | ").map { $0.split(separator: " ") } }

// MARK: - Part 1

let knowns = chop.flatMap { row in row[1].filter { [2, 3, 4, 7].contains($0.count) } }
print("*  There are \(knowns.count) known readout values")

// MARK: - Part 2

func decodeRow(digits: [Substring]) -> [Set<Character>: Int] {
  let one = Set(digits.first { $0.count == 2 }!)
  let four = Set(digits.first { $0.count == 4 }!)
  let seven = Set(digits.first { $0.count == 3 }!)
  let eight = Set(digits.first { $0.count == 7 }!)

  let twoThreeFive = Set(digits.filter({ $0.count == 5 }).map { Set($0) })
  
  let three = twoThreeFive.first { $0.intersection(one) == one }!
  let five = twoThreeFive.first { $0.intersection(four.subtracting(one)) == four.subtracting(one) }!
  let two = twoThreeFive.subtracting([three, five]).first!
  
  let zeroSixNine = Set(digits.filter({ $0.count == 6 }).map { Set($0) })
  let six = zeroSixNine.first { $0.intersection(one) != one}!
  let nine = zeroSixNine.first { $0.intersection(four) == four}!
  let zero = zeroSixNine.subtracting([six, nine]).first!
  
  return [zero: 0, one: 1, two: 2, three: 3, four: 4, five: 5, six: 6, seven: 7, eight: 8, nine: 9]
}

let readouts: [Int] = chop.map { row in
  let dDict = decodeRow(digits: row[0])
  return row[1].map { dDict[Set($0)]! }.reduce(0, { $0 * 10 + $1 })
}

let sum = readouts.reduce(0, +)
print("** the sum of all readout values is \(sum)")

