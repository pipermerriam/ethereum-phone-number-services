# Phone Number services for ethereum

An Ethereum based service for doing verification of phone
number ownership for ethereum addresses.

# How it works

* The verification service will have a set of active relay-contracts `C`
* Each relay-contract `c` from the set of relay-contracts `C` will have an
  associated extenal entity `r`, referred to as simply the *relay*.
* Each relay-contract `c` has an associated verified phone number `r_n`.

1.  client calls function `initiatePhoneNumberVerification` with phone number
    `t_n` and address `t_a` and fee `t_f`.
2.  Randomly pick a relay-contract `c` from the active relay-contract set `C`.
3.  Check if relay-contract `c` is willing to relay by calling `willRelay()`.
    If this returns *false* then repeat step 2.
4.  Return from `initiatePhoneNumberVerification` call with a secret `s_0` and
    relay phone number `r_n`.
5.  client sends SMS to `r_n` with secret `s_0`.
6.  relay `r` receives SMS message with secret `s_0`.
7.  relay-contract `c` calls `reportMessage` with secret `s_0` and deposit `r_d`.
8.  `s_0` is looked up and validated.  If invalid, deposit `r_d` is returned to
    `c`.
9.  Return from `reportMessage` with phone number `t_n` and secret `s_1`.
10. `r` retreives `t_n` and `s_1` from relay-contract `c` and sends SMS message
    with secret `s_1` to client.
11. client receives message and calls `reportMessage` with secret `s_1`.
    The relay-contract `c` is refunded deposit `r_d` and paid a portion of fee
    `t_f`.  The client is refunded the remainder of `t_f` minus expenses.  The
    service stores `t_n` as a verified phone number for `t_a`.

## Contesting Deposit Forfeiture

A relay-contract must put up a deposit each time it agrees to send an SMS
message on behalf of the verification service.  The deposit is returned upon
successful verification.

In the event that the client abandons the process before reporting back to the
service, a relay-contract's deposit is returned to them (though exactly how
this mechanism works is still to be figured out).

In the event that the client claims they did not receive a message or that the
message that they received does not validate, the client can call the
`resendMessage` function on the service to initiate sending a new verification
code.  In this case, a new relay-contract `c_1` is chosen and asked to send a
new secret `s_2`.

If the client verifies via the new relay, the original relay-contract loses
their deposit, the new relay-contract `c_1` is paid a smaller portion of the
fee `t_f`, and the client is refunded the remainder of `t_f` minus expenses.

If the client fails to verify, this is repeated until a total of `4` relays
(this should be configurable) have participated, each for a smaller portion of
fee `t_f`.  Once maximum number of relays has been met and the client has not
verified, all participating relays are paid their portion of `t_f` and refunded
their deposits.


# Contract APIS

## Relay Contracts

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

## Verification Contracts

To initialiate phone number verificaton, call this contract with
`initiatePhoneNumberVerification(phoneNumber)`.

**Outbound Verification**

The call to the `initiatePhoneNumberVerification` function will return
`relayNumber` and `smsMessage`.  The person in posession of the `phoneNumber`
which is being verified should send that to the `relayNumber` (who will then
call the `receivedSMS` function).

** Inbound Verification**

When the `initiatePhoneNumberVerification` function is called, this contract
will use the registered relay-contracts to initiate an SMS message to the
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
* SMSVerification - responsible for interfacing with relay-contracts.
* Relay - One contract for each registered relay.
* Need a system for divying up based on country codes.

# TODO

* Figure out how to *regulate* the relay-contracts.  
    * They need to get paid
    * They need to be penalized somehow for not relaying.
