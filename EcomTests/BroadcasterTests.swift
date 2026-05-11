//
//  BroadcasterTests.swift
//  EcomTests
//

import Testing
import Foundation
@testable import Ecom

@Suite("Broadcaster Tests")
struct BroadcasterTests {
    @Test func testSingleSenderMultipleSubscribers() async throws {
        let broadcaster = Broadcaster<Int>()
        
        var stream1 = await broadcaster.subscribe().makeAsyncIterator()
        var stream2 = await broadcaster.subscribe().makeAsyncIterator()
        var stream3 = await broadcaster.subscribe().makeAsyncIterator()
        
        await broadcaster.send(42)
        
        let val1 = await stream1.next()
        let val2 = await stream2.next()
        let val3 = await stream3.next()
        
        #expect(val1 == 42)
        #expect(val2 == 42)
        #expect(val3 == 42)
    }
    
    @Test func testLastValueGivenImmediately() async throws {
        let broadcaster = Broadcaster<String>()
        await broadcaster.send("Hello")
        
        var stream = await broadcaster.subscribe().makeAsyncIterator()
        let val = await stream.next()
        #expect(val == "Hello")
    }
    
    @Test func testUnsubscribeDoesNotBreakOthers() async throws {
        let broadcaster = Broadcaster<Int>()
        
        let s1 = await broadcaster.subscribe()
        var s2 = await broadcaster.subscribe().makeAsyncIterator()
        
        await broadcaster.send(1)
        
        // break s1
        let task = Task {
            for await _ in s1 {
                break
            }
        }
        await task.value
        
        // wait for onTermination
        try? await Task.sleep(for: .milliseconds(100))
        
        await broadcaster.send(2)
        
        _ = await s2.next() // 1
        let val2 = await s2.next() // 2
        #expect(val2 == 2)
    }
}
