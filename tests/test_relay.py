def test_submitting_a_secret(deployed_contracts, eth_coinbase):
    relay = deployed_contracts.Relay
    n = relay.getNumSecrets.call(_from=eth_coinbase)

    assert n == 0

    relay.addSecret.sendTransaction('a-secret', _from=eth_coinbase)
    n = relay.getNumSecrets.call(_from=eth_coinbase)

    assert n == 1

    secret = relay.getLatestSecret.call(False, _from=eth_coinbase)
    relay.getLatestSecret.sendTransaction(True, _from=eth_coinbase)
    n = relay.getNumSecrets.call(_from=eth_coinbase)

    assert n == 0
    assert secret == 'a-secret'
