# Phone Number services for ethereum

An Ethereum based service for doing verification of phone
number ownership for ethereum addresses.

# How it works

## Relays

Since ethereum contracts cannot interact with the outside
world, this service relies on **relays** to execute the actual
phone based interactions.  A relay is an ethereum contract or
*relay-contract* and an external entity (such as a web-based
service) that will do things like send SMS messages on this
service's behalve.

A relay performs the following functions.

**Respond to SMS**

When a relay receives an SMS, it will call
`receivedSMS(fromNumber, smsMessage)` on its
*relay-contract*.  


**Send SMS**

This service will call `sendSMS(toNumber, smsMessage)` on a
*relay-contract*.  This function stores the SMS locally on the
contract which the external service is expected to pick up and
send over SMS to the `toNumber`.

** Retrieve SMS**

The external entity related to the *relay-contract* will monitor
the contract and call `retrieveSMS()` which will return the
`toNumber/smsMessage` pair that is queued to be sent.

## Verification

To initialiate phone number verificaton, call this contract with
`initiatePhoneNumberVerification(phoneNumber)`.

**Outbound Verification**

The call to the `initiatePhoneNumberVerification` function will return
`relayNumber` and `smsMessage`.  The person in posession of the `phoneNumber`
which is being verified should send that to the `relayNumber` (who will then
call the `receivedSMS` function).

** Inbound Verification**

When the `initiatePhoneNumberVerification` function is called, this contract
will use the registered relay contracts to initiate an SMS message to the
provide `phoneNumber`.  Upon receiving the message, the person in posession of
`phoneNumber` is expected to call the `receivedSMS` function with the the
message they were sent.

# Notes

* Since it appears that a contract cannot actually keep a secret, it appears
  that this will require the **whisper** network so that the sms code can be
  encrypted before returned.
* Should `PhoneNumberDatabase` be the primary interface?
* The `SMSVerification` contract needs to be replacable since the current
  approach could be fundamentally broken.

# Design

Contracts

* PhoneNumberDatabase - responsible for storing the mapping between operators
  and their phone numbers.
* SMSVerification - responsible for interfacing with relay contracts.
* Relay - One contract for each registered relay.

# TODO

* Figure out how to *regulate* the relay contracts.  
    * They need to get paid
    * They need to be penalized somehow for not relaying.
