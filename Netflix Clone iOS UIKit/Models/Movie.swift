
import Foundation

struct TrendingMoviesResponse : Codable {
    let results: [Movie]
}

struct Movie : Codable {
    let id: Int
    let mediaType: String?
    let originalName: String?
    let originalTitle: String?
    let posterPath: String?
    let overview: String?
    let voteCount: Int
    let voteAverage: Double
    let releaseData: String?
}
