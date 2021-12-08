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
  var segments = [Int: Character]()
  let one = Set(digits.first(where: { $0.count == 2 })!)
  let four = Set(digits.first(where: { $0.count == 4 })!)
  let seven = Set(digits.first(where: { $0.count == 3 })!)
  let eight = Set(digits.first(where: { $0.count == 7 })!)
  var digitDict = [one: 1, four: 4, seven: 7, eight: 8]

  let seg1 = seven.symmetricDifference(one).first!
  segments[1] = seg1
  
  let zeroSixNine = Set(digits.filter({ $0.count == 6 }).map { Set($0) })

  let nine = Set(zeroSixNine.filter({ digit in four.union(seven).allSatisfy({ digit.contains($0) }) }).first!)
  digitDict[nine] = 9
  segments[7] = nine.symmetricDifference(four.union(seven)).first!

  segments[5] = eight.symmetricDifference(nine).first!

  var zeroSix = zeroSixNine
  zeroSix.remove(nine)
  let zeroS = zeroSix.filter({ digit in one.allSatisfy({ digit.contains($0) }) })
  let zero = zeroS.first!
  digitDict[zero] = 0
  let sixS = zeroSix.symmetricDifference(zeroS)
  let six = sixS.first!
  digitDict[six] = 6
  
  var five = six
  five.remove(segments[5]!)
  digitDict[five] = 5

  segments[4] = eight.symmetricDifference(zero).first!
  segments[3] = eight.symmetricDifference(six).first!
  
  var seg6 = one
  seg6.remove(segments[3]!)
  segments[6] = seg6.first!
  
  var seg2 = four.symmetricDifference(one)
  seg2.remove(segments[4]!)
  segments[2] = seg2.first!
  
  var three = nine
  three.remove(segments[2]!)
  digitDict[three] = 3
  let two = Set([segments[1]!, segments[3]!, segments[4]!, segments[5]!, segments[7]!])
  digitDict[two] = 2
  
  return digitDict
}

let readouts: [Int] = chop.map { row in
  let dDict = decodeRow(digits: row[0])
  return row[1].map { dDict[Set($0)]! }.reduce(0, { $0 * 10 + $1 })
}

let sum = readouts.reduce(0, +)
print("** the sum of all readout values is \(sum)")

