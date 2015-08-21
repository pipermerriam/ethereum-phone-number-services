import "owned";


contract PhoneNumberDatabase is owned {
        struct Record {
                bytes32 key;
                bytes32 phoneNumber;
                address operator;
        }
        mapping (bytes32 => Record) records;

        struct PhoneRecord {
                bytes32 phoneNumber;
                bytes32[] records;
        }
        mapping (bytes32 => PhoneRecord) phoneRecords;

        struct OperatorRecord {
                address operator;
                bytes32[] records;
        }
        mapping (address => OperatorRecord) operatorRecords;

        function PhoneNumberDatabase() {
        }

        function generateRecordKey(bytes32 phoneNumber, address operator) internal returns (bytes32 key){
                key = sha3(phoneNumber, operator);
                return key;
        }

        function registerPhoneNumber(bytes32 phoneNumber, address operator) public {
                /*
                 * Stores an association between a phone number and an address.
                 */
                bytes32 recordKey = generateRecordKey(phoneNumber, operator);
                var record = records[recordKey];
                // TODO: Only need to do this if they are unset.
                if (record.operator == 0x0) {
                        record.phoneNumber = phoneNumber;
                        record.operator = operator;

                        var phoneRecord = phoneRecords[phoneNumber];
                        phoneRecord.phoneNumber = phoneNumber;
                        phoneRecord.records.length += 1;
                        phoneRecord.records[phoneRecord.records.length - 1] = recordKey;

                        var operatorRecord = operatorRecords[operator];
                        operatorRecord.operator = operator;
                        operatorRecord.records.length += 1;
                        operatorRecord.records[operatorRecord.records.length - 1] = recordKey;
                }
        }

        function checkPhoneNumber(bytes32 phoneNumber, address operator) public returns (bool isAssociated) {
                bytes32 recordKey = generateRecordKey(phoneNumber, operator);
                var record = records[recordKey];
                return (record.phoneNumber == phoneNumber && record.operator == operator);

        }
}
