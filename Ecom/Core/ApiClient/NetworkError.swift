//
//  NetworkError.swift
//  Ecom
//
//  Created by Vladimir Rogozhkin on 2026/04/26.
//

import Foundation

public enum NetworkError: Error, Sendable {
    case invalidURL
    case requestFailed
    case decodingFailed
}
