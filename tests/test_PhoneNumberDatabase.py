def test_phone_number_registration(deployed_contracts, eth_coinbase):
    phone_db = deployed_contracts.PhoneNumberDatabase

    is_registered = phone_db.checkPhoneNumber.call("409-291-8432", eth_coinbase, _from=eth_coinbase)
    assert not is_registered

    # register a phone number
    phone_db.registerPhoneNumber.sendTransaction("409-291-8432", eth_coinbase, _from=eth_coinbase)
    is_registered = phone_db.checkPhoneNumber.call("409-291-8432", eth_coinbase, _from=eth_coinbase)

    assert is_registered
