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


let strs = input.split(separator: "\n")
let nums = strs.compactMap { Int($0, radix: 2) }

let positions = strs.first!.count

// MARK: - Part 1

let half = nums.count / 2

let bitCounts = nums.reduce(into: Array(repeating: 0, count: positions)) { (counts, num) in
  var position = 0, num = num
  while num > 0 {
    if !num.isMultiple(of: 2) { counts[position] += 1 }
    position += 1
    num >>= 1
  }
}

let oneBit = bitCounts.map { $0 >= half }
var gamma = 0, epsilon = 0
for bit in oneBit.reversed() {
  gamma <<= 1
  epsilon <<= 1
  if bit { gamma += 1 } else { epsilon += 1 }
}
print("* gamma: \(gamma), epsilon: \(epsilon), power consumption: \(gamma * epsilon)")

// MARK: - Part 2

extension Int {
  func bitSetAtPosition(_ i: Int) -> Bool {
    self & (1 << i) > 0
  }
}

func reduceToOne(_ arr: [Int], leastCommon: Bool = false, pos: Int = positions - 1) -> Int? {
  guard arr.count > 1 && pos >= 0 else { return arr.first }
  let (zeros, ones) = arr.reduce(into: ([Int](), [Int]())) { (current, num) in
    current = num.bitSetAtPosition(pos) ? (current.0, current.1 + [num]) : (current.0 + [num], current.1)
  }
  var next: [Int]
  if leastCommon {
    next = zeros.count <= ones.count ? zeros : ones
  } else {
    next = ones.count >= zeros.count ? ones : zeros
  }
  return reduceToOne(next, leastCommon: leastCommon, pos: pos - 1)
}

guard let oxy = reduceToOne(nums) else { fatalError("Dunno… no oxy.") }
//print()
guard let co2 = reduceToOne(nums, leastCommon: true) else { fatalError("Dunno… no c02.") }
print("* oxyRating: \(oxy), co2 scrubber: \(co2), life support: \(oxy * co2)")
