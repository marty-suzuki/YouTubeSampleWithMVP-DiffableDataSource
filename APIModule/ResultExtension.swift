import Foundation

extension Result: Decodable where Success: Decodable, Failure == Error {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            self = try .success(container.decode(Success.self))
        } catch {
            self = .failure(error)
        }
    }
}
