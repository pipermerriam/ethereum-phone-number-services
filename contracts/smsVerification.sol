//sol Phone Number Database
// @authors
// Piper Merriam <pipermerriam@gmail.com>
// A contract that stores a many-to-many relationship between phone numbers and
// addresses that are verified operators of that phone number.
contract PhoneNumberDatabase {
        // `owner` is the main phone number verification contract
        address owner;
        address verificationContract;

        struct Verification {
                uint createdAt;
                address operator;
                bytes32 phoneNumber;
        }

        mapping (address => bytes32) operator_to_phoneNumber;
        mapping (bytes32 => Verification) phoneNumber_to_verification;

        // Initializer
        function PhoneNumberDatabase() {
                // Set the owner of the contract to be the creator of this
                // TODO: this should create the initial smsVerification contract.
                owner = msg.sender;
                verificationContract = new smsVerification();
        }

        // Management
        // TODO: What sort of management should go in place here.
        // - need a way to point at a new smsVerification contract.
        function updateVerificationContract(address newContract) {
                // TODO: enforce permissions here.
                verificationContract = newContract;
        }

        // Database API
        function add(address operator, bytes32 phoneNumber) {
                // TODO: enforce permissions here.
                // Add a phone number to the database.
                var verification = phoneNumber_to_verification[phoneNumber];
                verification.phoneNumber = phoneNumber;
                // TODO: we might be overriding another verification...  At a
                // minimum, we need to cleanup the `operator_to_phoneNumber`
                // entries.
                verification.operator = operator;
                // TODO: don't just squash createdAt
                verification.createdAt = msg.now;
        }

        function remove(address operator, bytes32 phoneNumber) {
                // Remove a phone number to the database.
        }

        function check(address operator, bytes32 phoneNumber) {
                // Lookup whether the operator is verified with the given phone
                // number.
        }
}


//sol SMS Verification
// @authors
// Piper Merriam <pipermerriam@gmail.com>
// SMS based phone number verification.
contract SMSVerification {
        // `owner` is the main phone number verification contract
        address owner;
        address[] relays;

        //
        //  Constants
        //

        // Sentinal value for signaling that no relays are available.
        int const NO_RELAY_AVAILABLE = -1;

        // Messages are valid for 5 minutes (300 seconds).
        uint const MESSAGE_VALIDITY_SECONDS = 300;

        // The amount in wei that verification costs. 
        // TODO: figure out a real number for this.
        uint const VERIFICATION_DEPOSIT = 100000000000000
        uint const RELAY_DEPOSIT = 1000000000

        struct SMSMessage {
                bytes32 unverifiedNumber;
                address unverifiedAddress;
                address relay;
                bool isVerified;
                bytes32 secret;
                uint createdAt;
                uint expiresAt;
                uint deposit;
        };

        struct Operator {
                mapping (bytes32 => SMSMessage) smsMessages;
        };

        mapping (address => Operator) address_to_operator;

        // For looking up which address a secret was intended for.
        mapping (bytes32 => address) secret_to_address;

        // Initializer
        function SMSVerification() {
                // Set the owner of the contract to be the creator of this
                owner = msg.sender;
        }

        // Management
        // TODO: What sort of management should go in place here.


        // Private API
        function getRandomRelayIndex() private returns (int relayIndex) {
                if ( relays.length == 0 )
                        return NO_RELAY_AVAILABLE;
                for (var i = 0; i < relays.length; i++)
                {
                    // Pick a random relay using `block.blockhash()` as the random
                    // number generator.
                    int relayIndex = (uint(block.blockhash()) + i) % relays.length;

                    // Check whether the relay is willing to relay the message over SMS
                    if ( relays[relayIndex].willRelay() ) {
                        return relayIndex;
                    }
                }
                return NO_RELAY_AVAILABLE;
        }

        function generateMessage(address unverifiedAddress, bytes32 unverifiedNumber, address relay) private returns (SMSMessage message) {
                // TODO: this should generate a short, human readable
                // string rather than a sha3.  Figure out how to do this.
                bytes32 secret = sha3(block.blockhash, msg.data);

                // store the mapping from this message's secret 
                secret_to_address[secret] = unverifiedAddress;

                var operator = address_to_operator[unverifiedAddress]
                var message = operator.smsMessage[secret];

                if ( message.expiresAt > 0 && msg.now < message.expiresAt ) {
                        // The message is active.

                        // TODO: This case needs more careful consideration.  If
                        // this message already exists and is not expired we are
                        // likely experiencing a hash collision and should do
                        // something other than just add to the deposit.

                        // Keep track of the users deposit.
                        message.deposit += msg.value;
                }
                else {
                        // The message is either expired or new
                        uint expiresAt = msg.now + MESSAGE_VALIDITY_SECONDS;

                        message.unverifiedAddress = unverifiedAddress;
                        message.unverifiedNumber = unverifiedNumber;
                        message.relay = relay;
                        message.isVerified = false;
                        message.secret = secret;
                        message.createdAt = msg.now;
                        message.expiresAt = expiresAt;
                        message.deposit = msg.value;
                }

                return message;
        }

        function getMessageForSecret(bytes32 secret) private returns (SMSMessage message) {
                _address = secret_to_address[secret]
                operator = address_to_operator[_address]
                
                message = operator.smsMessages[secret]
                return message;
        }

        function checkSecret(bytes32 secret) private returns (bool isValid) {
                // - message not already verified.
                // - is non-zero
                // - equal to `message.secret`
                // - not expired
                message = getMessageForSecret(secret);

                if ( message.isVerified ) {
                        return false;
                }
                if ( secret.length == 0 ) {
                        return false;
                } 
                if ( secret != message.secret ) {
                        return false;
                }
                if ( message.expiresAt > 0 && msg.now > message.expiresAt ) {
                        return false;
                }
                return true;
        }

        //
        // Verification API
        //
        function initiateVerification(bytes32 phoneNumber) returns (SMSMessage smsMessage) {
                // Check that the message was paid for.
                if ( msg.value < VERIFICATION_DEPOSIT ) {
                    // fail: did not pay enough.
                }

                int relayIndex = getRandomRelay();

                // Check that there is a relay available.
                if ( relayIndex == NO_RELAY_AVAILABLE ) {
                    // fail: no relays available.
                }

                address relay = relays[relayIndex];

                var message = generateMessage(msg.sender, phoneNumber, relay);

                return message;
        }

        function reportOutboundMessage(bytes32 secret) returns (bool isValid){
                // Check that the relay sent in a deposit.
                if ( msg.value < RELAY_DEPOSIT ) {
                        return false;
                }

                bool isValid = checkSecret(secret);

                if ( isValid ) {
                        var confirmedMessage = getMessageForSecret(secret);

                        // Check that the sender of this message is the relay that we
                        // expected to receive it.
                        if ( msg.sender != confirmedMessage.relay ) {
                                return false;
                        }

                        // Mark the message as confirmed.
                        confirmedMessage.isVerified = true;

                        // The message is valid.  Now the relay needs to be
                        // told to send them a message.
                        var message_for_relay = generateMessage(confirmedMessage.unverifiedAddress, confirmedMessage.unverifiedNumber, confirmedMessage.relay);
                        var relay = Relay(confirmedMessage.relay);
                        relay.sendSMS(message_for_relay);

                        // Cleanup the secret to message mapping;
                        delete secret_to_address[secret]
                }
                else {
                        // return their deposit.
                        // TODO: this should really throw an exception or
                        // something but that isn'd doable right now in
                        // solidity.
                        msg.sender.send(msg.value);
                }

                return isValid;
        }

        function verifyPhoneNumber(bytes32 secret) returns (bool isVerified) {
                bool isValid = checkSecret(secret);

                if ( isValid ) {
                        var confirmedMessage = getMessageForSecret(secret);

                        // Return the relay's deposit
                        // TODO: this should actually return the relay's
                        // deposit + some of the other deposit.
                        confirmedMessage.relay.send(confirmedMessage.deposit);

                        // Check that the sender of this message is the relay that we
                        // expected to receive it.
                        if ( msg.sender != confirmedMessage.unverifiedAddress ) {
                                return false;
                        }

                        delete secret_to_address[secret]

                        // TODO: this should be less some amount that was paid
                        // to this contract as well as the amount paid towards
                        // the relay for their services.
                        msg.sender.send(VERIFICATION_DEPOSIT);

                        // Store the address as being verified owning the phone
                        // number.
                        var database = PhoneNumberDatabase(owner);
                        database.add(confirmedMessage.unverifiedAddress, confirmedMessage.unverifiedNumber);
                }
                return isValid;
        }
}


//sol SMS Relay
// @authors
// Piper Merriam <pipermerriam@gmail.com>
// A utility contract that facilitates the sending of SMS messages.
contract SMSRelay {
        // `owner` is the main phone number verification contract
        address owner;
        // `operator` is the address of the ethereum account that is operating this
        // relay.
        address operator;
        // `phoneNumber` is the phone number that this relay will be using to send
        // SMS messages.
        bytes32 phoneNumber;

        // Initializer
        function SMSRelay(address operator, bytes32 phoneNumber) {
                // Set the owner of the contract to be the creator of this
                owner = msg.sender;
                operator = operator;
                phoneNumber = phoneNumber;
        }

        // Management
        function kill() {
                // `suicide` this contract and do something with the funds...
        }
        function withdraw() {
                // move some amount of the funds under this contract's control
                // to the `operator` address.
        }

        // Relay API
        function willRelay() returns (bool is_willing_to_relay) {
                // TODO: remove hard coded value.
                return true;
        }

        function receivedSMS(bytes32 fromNumber, bytes32 smsMessage) {
                // Report the message to the owner contract via the `reportSMSReceipt`
                owner.reportSMSReceipt(fromNumber, smsMessage)
        }

        function sendSMS(bytes32 toNumber, bytes32 smsMessage) {
                // Queue a message to be sent.
                // TODO: how does this work.  Over whisper? or via an internal queue?
        }
}
