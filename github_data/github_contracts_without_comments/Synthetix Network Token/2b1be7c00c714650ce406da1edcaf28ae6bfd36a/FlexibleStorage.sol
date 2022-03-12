pragma solidity ^0.5.16;


import ;
import ;


import ;



contract flexiblestorage is contractstorage, iflexiblestorage {
    mapping(bytes32 => mapping(bytes32 => uint)) internal uintstorage;
    mapping(bytes32 => mapping(bytes32 => int)) internal intstorage;
    mapping(bytes32 => mapping(bytes32 => address)) internal addressstorage;
    mapping(bytes32 => mapping(bytes32 => bool)) internal boolstorage;
    mapping(bytes32 => mapping(bytes32 => bytes32)) internal bytes32storage;

    constructor(address _resolver) public contractstorage(_resolver) {}

    

    function _setuintvalue(
        bytes32 contractname,
        bytes32 record,
        uint value
    ) internal {
        uintstorage[_memoizehash(contractname)][record] = value;
        emit valuesetuint(contractname, record, value);
    }

    function _setintvalue(
        bytes32 contractname,
        bytes32 record,
        int value
    ) internal {
        intstorage[_memoizehash(contractname)][record] = value;
        emit valuesetint(contractname, record, value);
    }

    function _setaddressvalue(
        bytes32 contractname,
        bytes32 record,
        address value
    ) internal {
        addressstorage[_memoizehash(contractname)][record] = value;
        emit valuesetaddress(contractname, record, value);
    }

    function _setboolvalue(
        bytes32 contractname,
        bytes32 record,
        bool value
    ) internal {
        boolstorage[_memoizehash(contractname)][record] = value;
        emit valuesetbool(contractname, record, value);
    }

    function _setbytes32value(
        bytes32 contractname,
        bytes32 record,
        bytes32 value
    ) internal {
        bytes32storage[_memoizehash(contractname)][record] = value;
        emit valuesetbytes32(contractname, record, value);
    }

    

    function getuintvalue(bytes32 contractname, bytes32 record) external view returns (uint) {
        return uintstorage[hashes[contractname]][record];
    }

    function getuintvalues(bytes32 contractname, bytes32[] calldata records) external view returns (uint[] memory) {
        uint[] memory results = new uint[](records.length);

        mapping(bytes32 => uint) storage data = uintstorage[hashes[contractname]];
        for (uint i = 0; i < records.length; i++) {
            results[i] = data[records[i]];
        }
        return results;
    }

    function getintvalue(bytes32 contractname, bytes32 record) external view returns (int) {
        return intstorage[hashes[contractname]][record];
    }

    function getintvalues(bytes32 contractname, bytes32[] calldata records) external view returns (int[] memory) {
        int[] memory results = new int[](records.length);

        mapping(bytes32 => int) storage data = intstorage[hashes[contractname]];
        for (uint i = 0; i < records.length; i++) {
            results[i] = data[records[i]];
        }
        return results;
    }

    function getaddressvalue(bytes32 contractname, bytes32 record) external view returns (address) {
        return addressstorage[hashes[contractname]][record];
    }

    function getaddressvalues(bytes32 contractname, bytes32[] calldata records) external view returns (address[] memory) {
        address[] memory results = new address[](records.length);

        mapping(bytes32 => address) storage data = addressstorage[hashes[contractname]];
        for (uint i = 0; i < records.length; i++) {
            results[i] = data[records[i]];
        }
        return results;
    }

    function getboolvalue(bytes32 contractname, bytes32 record) external view returns (bool) {
        return boolstorage[hashes[contractname]][record];
    }

    function getboolvalues(bytes32 contractname, bytes32[] calldata records) external view returns (bool[] memory) {
        bool[] memory results = new bool[](records.length);

        mapping(bytes32 => bool) storage data = boolstorage[hashes[contractname]];
        for (uint i = 0; i < records.length; i++) {
            results[i] = data[records[i]];
        }
        return results;
    }

    function getbytes32value(bytes32 contractname, bytes32 record) external view returns (bytes32) {
        return bytes32storage[hashes[contractname]][record];
    }

    function getbytes32values(bytes32 contractname, bytes32[] calldata records) external view returns (bytes32[] memory) {
        bytes32[] memory results = new bytes32[](records.length);

        mapping(bytes32 => bytes32) storage data = bytes32storage[hashes[contractname]];
        for (uint i = 0; i < records.length; i++) {
            results[i] = data[records[i]];
        }
        return results;
    }

    
    function setuintvalue(
        bytes32 contractname,
        bytes32 record,
        uint value
    ) external onlycontract(contractname) {
        _setuintvalue(contractname, record, value);
    }

    function setuintvalues(
        bytes32 contractname,
        bytes32[] calldata records,
        uint[] calldata values
    ) external onlycontract(contractname) {
        require(records.length == values.length, );

        for (uint i = 0; i < records.length; i++) {
            _setuintvalue(contractname, records[i], values[i]);
        }
    }

    function deleteuintvalue(bytes32 contractname, bytes32 record) external onlycontract(contractname) {
        uint value = uintstorage[hashes[contractname]][record];
        emit valuedeleteduint(contractname, record, value);
        delete uintstorage[hashes[contractname]][record];
    }

    function setintvalue(
        bytes32 contractname,
        bytes32 record,
        int value
    ) external onlycontract(contractname) {
        _setintvalue(contractname, record, value);
    }

    function setintvalues(
        bytes32 contractname,
        bytes32[] calldata records,
        int[] calldata values
    ) external onlycontract(contractname) {
        require(records.length == values.length, );

        for (uint i = 0; i < records.length; i++) {
            _setintvalue(contractname, records[i], values[i]);
        }
    }

    function deleteintvalue(bytes32 contractname, bytes32 record) external onlycontract(contractname) {
        int value = intstorage[hashes[contractname]][record];
        emit valuedeletedint(contractname, record, value);
        delete intstorage[hashes[contractname]][record];
    }

    function setaddressvalue(
        bytes32 contractname,
        bytes32 record,
        address value
    ) external onlycontract(contractname) {
        _setaddressvalue(contractname, record, value);
    }

    function setaddressvalues(
        bytes32 contractname,
        bytes32[] calldata records,
        address[] calldata values
    ) external onlycontract(contractname) {
        require(records.length == values.length, );

        for (uint i = 0; i < records.length; i++) {
            _setaddressvalue(contractname, records[i], values[i]);
        }
    }

    function deleteaddressvalue(bytes32 contractname, bytes32 record) external onlycontract(contractname) {
        address value = addressstorage[hashes[contractname]][record];
        emit valuedeletedaddress(contractname, record, value);
        delete addressstorage[hashes[contractname]][record];
    }

    function setboolvalue(
        bytes32 contractname,
        bytes32 record,
        bool value
    ) external onlycontract(contractname) {
        _setboolvalue(contractname, record, value);
    }

    function setboolvalues(
        bytes32 contractname,
        bytes32[] calldata records,
        bool[] calldata values
    ) external onlycontract(contractname) {
        require(records.length == values.length, );

        for (uint i = 0; i < records.length; i++) {
            _setboolvalue(contractname, records[i], values[i]);
        }
    }

    function deleteboolvalue(bytes32 contractname, bytes32 record) external onlycontract(contractname) {
        bool value = boolstorage[hashes[contractname]][record];
        emit valuedeletedbool(contractname, record, value);
        delete boolstorage[hashes[contractname]][record];
    }

    function setbytes32value(
        bytes32 contractname,
        bytes32 record,
        bytes32 value
    ) external onlycontract(contractname) {
        _setbytes32value(contractname, record, value);
    }

    function setbytes32values(
        bytes32 contractname,
        bytes32[] calldata records,
        bytes32[] calldata values
    ) external onlycontract(contractname) {
        require(records.length == values.length, );

        for (uint i = 0; i < records.length; i++) {
            _setbytes32value(contractname, records[i], values[i]);
        }
    }

    function deletebytes32value(bytes32 contractname, bytes32 record) external onlycontract(contractname) {
        bytes32 value = bytes32storage[hashes[contractname]][record];
        emit valuedeletedbytes32(contractname, record, value);
        delete bytes32storage[hashes[contractname]][record];
    }

    

    event valuesetuint(bytes32 contractname, bytes32 record, uint value);
    event valuedeleteduint(bytes32 contractname, bytes32 record, uint value);

    event valuesetint(bytes32 contractname, bytes32 record, int value);
    event valuedeletedint(bytes32 contractname, bytes32 record, int value);

    event valuesetaddress(bytes32 contractname, bytes32 record, address value);
    event valuedeletedaddress(bytes32 contractname, bytes32 record, address value);

    event valuesetbool(bytes32 contractname, bytes32 record, bool value);
    event valuedeletedbool(bytes32 contractname, bytes32 record, bool value);

    event valuesetbytes32(bytes32 contractname, bytes32 record, bytes32 value);
    event valuedeletedbytes32(bytes32 contractname, bytes32 record, bytes32 value);
}
