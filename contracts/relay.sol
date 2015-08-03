//sol SMS Relay
// @authors
// Piper Merriam <pipermerriam@gmail.com>
// A utility contract that facilitates the sending of SMS messages.
contract SMSRelay {
  // `master` is the main phone number verification contract
  address master;
  // `operator` is the address of the ethereum account that is operating this
  // relay.
  address operator;
  // `phoneNumber` is the phone number that this relay will be using to send
  // SMS messages.
  bytes32 phoneNumber;

  // Initializer
  function SMSRelay(address operator, bytes32 phoneNumber) {
    // Set the owner of the contract to be the creator of this
    master = msg.sender;
    operator = operator;
    phoneNumber = phoneNumber;
  }

  // Relay API
  function receivedSMS(bytes32 fromNumber, bytes32 smsMessage) {
    // Report the message to the master contract via the `reportSMSReceipt`
    master.
  }
}
