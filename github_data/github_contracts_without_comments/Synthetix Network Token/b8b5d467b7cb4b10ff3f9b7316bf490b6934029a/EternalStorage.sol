pragma solidity ^0.5.16;


import ;
import ;




contract eternalstorage is owned, state {
    constructor(address _owner, address _associatedcontract) public owned(_owner) state(_associatedcontract) {}

    
    mapping(bytes32 => uint) internal uintstorage;
    mapping(bytes32 => string) internal stringstorage;
    mapping(bytes32 => address) internal addressstorage;
    mapping(bytes32 => bytes) internal bytesstorage;
    mapping(bytes32 => bytes32) internal bytes32storage;
    mapping(bytes32 => bool) internal booleanstorage;
    mapping(bytes32 => int) internal intstorage;

    
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

    function setstringvalue(bytes32 record, string calldata value) external onlyassociatedcontract {
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

    function setbytesvalue(bytes32 record, bytes calldata value) external onlyassociatedcontract {
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
