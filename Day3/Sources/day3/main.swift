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
let nums = input.split(separator: "\n")

let bits: [[Character]] = nums.map { Array($0) }


let byPosition = bits.reduce(into: Array(repeating: 0, count: bits.first!.count)) { (byPos, num) in
  for idx in num.indices { byPos[idx] += num[idx] == "1" ? 1 : 0 }
}

let half = nums.count / 2
print("byPosition", byPosition, ": half", half)

var gamma = 0, epsilon = 0
for bitCount in byPosition {
  gamma <<= 1
  epsilon <<= 1
  if bitCount > half {
    gamma += 1
  } else {
    epsilon += 1
  }
}

print("* gamma: \(gamma), epsilon: \(epsilon), power consumption: \(gamma * epsilon)")

func partition(_ arr: [Substring]) -> (zeros: [Substring], ones: [Substring]) {
  arr.reduce(into: (zeros: [Substring](), ones: [Substring]())) { (current, num) in
    if num.first! == "1" {
      current = (zeros: current.zeros, ones: current.ones + [num.dropFirst()])
    } else {
      current = (zeros: current.zeros + [num.dropFirst()], ones: current.ones)
    }
  }
}

var oxy = nums, oxyRating = 0, co2 = nums, co2Scrubber = 0

while oxy.count > 1 {
//  print("oxy:", oxy)
  oxyRating <<= 1
  let splits = partition(oxy)
  if splits.ones.count * 2 >= oxy.count {
    oxy = splits.ones
    oxyRating += 1
  } else {
    oxy = splits.zeros
  }
}
//print("oxy:", oxy)

for bit in oxy.first! {
  oxyRating <<= 1
  if bit == "1" { oxyRating += 1 }
}

while co2.count > 1 {
  co2Scrubber <<= 1
  let splits = partition(co2)
  if splits.ones.count * 2 < co2.count {
    co2 = splits.ones
    co2Scrubber += 1
  } else {
    co2 = splits.zeros
  }
}

for bit in co2.first! {
  co2Scrubber <<= 1
  if bit == "1" { co2Scrubber += 1 }
}


print("* oxyRating: \(oxyRating), co2 scrubber: \(co2Scrubber), life support: \(oxyRating * co2Scrubber)")
