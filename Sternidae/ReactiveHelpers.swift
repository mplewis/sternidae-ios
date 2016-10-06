import UIKit
import ReactiveSwift

class ReactiveHelpers {
    /**
     Transforms a Signal into a new Signal that yields the most recent `count` values in a continuous rolling window.
     
     For example: Using a `count` of 3 will transform an input `signal` of
     
     `[1, 2, 3, 4, 5]`
     
     into an output signal of
     
     `[[1, 2, 3], [2, 3, 4], [3, 4, 5]]`
     
     - parameters:
     - signal: The input Signal to transform
     - count: The number of latest items to return in the rolling window
     
     - returns: A signal that yields the most recent values in a continuous rolling window
     */
    class func rollingWindow<U, V>(signal: Signal<U, V>, count: Int) -> Signal<[U], V> {
        func sampleOnce<U, V>(signal: Signal<U, V>, start: Int, count: Int) -> Signal<[U], V> {
            return signal.skip(first: start).take(first: count).collect()
        }
        
        var eventCount = 0
        let (outSig, outObs) = Signal<[U], V>.pipe()
        
        let handler: (Event<[U], V>) -> () = { event in
            guard let sampled = event.value else { return }
            outObs.send(value: sampled)
        }
        
        // Not sure why I have to do this so many times. This returns the sample at index 0.
        sampleOnce(signal: signal, start: 0, count: count).observe(handler)
        signal.observe { event in
            guard let _ = event.value else {
                // This doesn't handle errors yet
                print("No value received")
                return
            }
            // This returns the sample at index 1, 3, 5...
            sampleOnce(signal: signal, start: eventCount, count: count).observe(handler)
            // This returns the sample at index 2, 4, 6... Not sure why I have to do this either.
            sampleOnce(signal: signal, start: eventCount + 1, count: count).observe(handler)
            eventCount += 1
        }
        return outSig
    }
}
