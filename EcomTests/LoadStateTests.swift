//
//  LoadStateTests.swift
//  EcomTests
//

import Testing
import Foundation
@testable import Ecom

@Suite struct LoadStateTests {
    @Test func freshExposesValueAndNotLoading() {
        let s: LoadState<Int, SampleError> = .fresh(7)
        #expect(s.value == 7)
        #expect(s.error == nil)
        #expect(!s.isLoading)
    }

    @Test func loadingHasNoValueAndNoError() {
        let s: LoadState<Int, SampleError> = .loading
        #expect(s.value == nil)
        #expect(s.error == nil)
        #expect(s.isLoading)
    }

    @Test func failedKeepsLastKnown() {
        let s: LoadState<Int, SampleError> = .failed(.boom, lastKnown: 42)
        #expect(s.value == 42)
        #expect(s.error == .boom)
        #expect(!s.isLoading)
    }
}

private enum SampleError: Error, Equatable { case boom }
