import Foundation

@main
struct CheckStreamRecovery {
	static func main() {
		var budget = StreamRecoveryBudget()
		precondition(budget.beginAttempt(at: 0))
		precondition(!budget.beginAttempt(at: 0.5))
		precondition(!budget.recordHealthy(at: 0.5))
		budget.recordFailure()
		precondition(budget.beginAttempt(at: 2))
		precondition(!budget.recordHealthy(at: 2.5))
		budget.recordFailure()
		precondition(!budget.beginAttempt(at: 6.9))
		precondition(budget.beginAttempt(at: 7))
		precondition(budget.isExhausted)
		for time in stride(from: 7.5, through: 60.0, by: 0.5) {
			precondition(!budget.recordHealthy(at: time))
			budget.recordFailure()
			precondition(!budget.beginAttempt(at: time))
		}
		precondition(budget.attempts == 3, "Intermittent OK frames must not enable endless retries")
		precondition(!budget.recordHealthy(at: 61))
		precondition(!budget.recordHealthy(at: 65.9))
		precondition(budget.recordHealthy(at: 66))
		precondition(budget.attempts == 0)
		budget.recordFailure()
		precondition(budget.beginAttempt(at: 66.1))
		budget.reset()
		precondition(budget.attempts == 0 && budget.lastAttemptAt == nil)

		var network = StreamNetworkRecovery()
		precondition(!network.needsReconnect(networkFailure: false, at: 0))
		precondition(!network.needsReconnect(networkFailure: true, at: 1))
		precondition(!network.needsReconnect(networkFailure: true, at: 3.9))
		precondition(network.needsReconnect(networkFailure: true, at: 4))
		precondition(!network.needsReconnect(networkFailure: false, at: 4.1))
		precondition(!network.needsReconnect(networkFailure: true, at: 5))
		network.didResume(at: 6)
		precondition(network.needsReconnect(networkFailure: true, at: 6))
		precondition(!network.needsReconnect(networkFailure: false, at: 6.1))
		precondition(!network.needsReconnect(networkFailure: true, at: 17))
		precondition(network.needsReconnect(networkFailure: true, at: 20))
		network.reset()
		precondition(!network.needsReconnect(networkFailure: true, at: 21))
		print("Stream recovery regression checks passed")
	}
}
