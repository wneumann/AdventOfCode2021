import Foundation
import ArgumentParser
import Algorithms

// MARK: - Command line parsing
struct RunOptions: ParsableArguments {
  @Argument(help: "The location of the input file.", transform: URL.init(fileURLWithPath:))
  var inURL: URL
}

let options = RunOptions.parseOrExit()

// MARK: - Actual work done here
let input = try String(contentsOf: options.inURL, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
let grid = input.split(separator: "\n").map { (sstr: Substring) in sstr.compactMap { Int("\($0)") } }

struct Point: Hashable {
  var r: Int
  var c: Int
}

func neighborsOf(_ point: Point, grid: [[Int]]) -> [Point] {
  [Point(r: point.r, c: point.c - 1),
   Point(r: point.r, c: point.c + 1),
   Point(r: point.r - 1, c: point.c),
   Point(r: point.r + 1, c: point.c)
  ].filter { 0..<grid.count ~= $0.r && 0..<grid[0].count ~= $0.c  }
}

// MARK: - Part 1

func findLowPoints(in grid: [[Int]]) -> [Point] {
  var lowPoints = [Point]()
  for r in grid.indices {
    for c in grid[r].indices {
      let level = grid[r][c]
      if level < 9  && neighborsOf(Point(r: r, c: c), grid: grid).allSatisfy({ grid[$0.r][$0.c] > level }) { lowPoints.append(Point(r: r, c: c)) }
    }
  }
  return lowPoints
}

let lowPoints = findLowPoints(in: grid)
let totalRisk = lowPoints.reduce(0, { $0 + grid[$1.r][$1.c] + 1 })

print("*  There is a total risk of \(totalRisk).")

// MARK: - Part 2

func findBasinIn(_ grid: [[Int]], at lowPoint: Point) -> Set<Point> {
  var basin = Set<Point>()
  var frontier = Set<Point>([lowPoint])

  while !frontier.isEmpty {
    frontier = Set(frontier.flatMap({ point in neighborsOf(point, grid: grid).filter { n in grid[n.r][n.c] < 9 && !basin.contains(n) } }))
    basin.formUnion(frontier)
  }
  
  return basin
}

let counts = lowPoints.map { findBasinIn(grid, at: $0) }.map(\.count).max(count: 3)
print("** The product of the three largest basin sizess is \(counts.reduce(1, *)).")
