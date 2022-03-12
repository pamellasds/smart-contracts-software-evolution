

pragma solidity 0.4.25;
import ;



contract eternalstorage is state {
    constructor(address _owner, address _associatedcontract) public state(_owner, _associatedcontract) {}

    
    mapping(bytes32 => uint) uintstorage;
    mapping(bytes32 => string) stringstorage;
    mapping(bytes32 => address) addressstorage;
    mapping(bytes32 => bytes) bytesstorage;
    mapping(bytes32 => bytes32) bytes32storage;
    mapping(bytes32 => bool) booleanstorage;
    mapping(bytes32 => int) intstorage;

    
    function getuintvalue(bytes32 record) external view returns (uint) {
        return uintstorage[record];
    }

    function setuintvalue(bytes32 record, uint value) external onlyassociatedcontract {
        uintstorage[record] = value;
    }

    function deleteuintvalue(bytes32 record) external onlyassociatedcontract {
        delete uintstorage[record];
    }

    
    function getstringvalue(bytes32 record) external view returns (string memory) {
        return stringstorage[record];
    }

    function setstringvalue(bytes32 record, string value) external onlyassociatedcontract {
        stringstorage[record] = value;
    }

    function deletestringvalue(bytes32 record) external onlyassociatedcontract {
        delete stringstorage[record];
    }

    
    function getaddressvalue(bytes32 record) external view returns (address) {
        return addressstorage[record];
    }

    function setaddressvalue(bytes32 record, address value) external onlyassociatedcontract {
        addressstorage[record] = value;
    }

    function deleteaddressvalue(bytes32 record) external onlyassociatedcontract {
        delete addressstorage[record];
    }

    
    function getbytesvalue(bytes32 record) external view returns (bytes memory) {
        return bytesstorage[record];
    }

    function setbytesvalue(bytes32 record, bytes value) external onlyassociatedcontract {
        bytesstorage[record] = value;
    }

    function deletebytesvalue(bytes32 record) external onlyassociatedcontract {
        delete bytesstorage[record];
    }

    
    function getbytes32value(bytes32 record) external view returns (bytes32) {
        return bytes32storage[record];
    }

    function setbytes32value(bytes32 record, bytes32 value) external onlyassociatedcontract {
        bytes32storage[record] = value;
    }

    function deletebytes32value(bytes32 record) external onlyassociatedcontract {
        delete bytes32storage[record];
    }

    
    function getbooleanvalue(bytes32 record) external view returns (bool) {
        return booleanstorage[record];
    }

    function setbooleanvalue(bytes32 record, bool value) external onlyassociatedcontract {
        booleanstorage[record] = value;
    }

    function deletebooleanvalue(bytes32 record) external onlyassociatedcontract {
        delete booleanstorage[record];
    }

    
    function getintvalue(bytes32 record) external view returns (int) {
        return intstorage[record];
    }

    function setintvalue(bytes32 record, int value) external onlyassociatedcontract {
        intstorage[record] = value;
    }

    function deleteintvalue(bytes32 record) external onlyassociatedcontract {
        delete intstorage[record];
    }
}
