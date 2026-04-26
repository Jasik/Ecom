//
//  NetworkClient.swift
//  Ecom
//
//  Created by Vladimir Rogozhkin on 2026/04/26.
//

import Foundation

protocol NetworkClient: Sendable {
    func fetch<T: Decodable>(url: String) async throws(NetworkError) -> T
}

public struct LiveNetworkClient: NetworkClient {
    public init() {}
    
    public func fetch<T: Decodable>(url: String) async throws(NetworkError) -> T {
        guard let validURL = URL(string: url) else { throw .invalidURL }
        do {
            let (data, response) = try await URLSession.shared.data(from: validURL)
            guard let http = response as? HTTPURLResponse, 200...299 ~= http.statusCode else {
                throw NetworkError.requestFailed
            }
            return try JSONDecoder().decode(T.self, from: data)
        } catch is DecodingError {
            throw .decodingFailed
        } catch {
            throw .requestFailed
        }
    }
}

private struct NetworkClientKey: DependencyKey { static let liveValue: any NetworkClient = LiveNetworkClient() }

extension DependencyValues {
    var apiClient: any NetworkClient { self[NetworkClientKey.self] }
}
