pragma solidity >=0.4.24;


interface iflexiblestorage {
    
    function getuintvalue(bytes32 contractname, bytes32 record) external view returns (uint);

    function getuintvalues(bytes32 contractname, bytes32[] calldata records) external view returns (uint[] memory);

    function getintvalue(bytes32 contractname, bytes32 record) external view returns (int);

    function getintvalues(bytes32 contractname, bytes32[] calldata records) external view returns (int[] memory);

    function getaddressvalue(bytes32 contractname, bytes32 record) external view returns (address);

    function getaddressvalues(bytes32 contractname, bytes32[] calldata records) external view returns (address[] memory);

    function getboolvalue(bytes32 contractname, bytes32 record) external view returns (bool);

    function getboolvalues(bytes32 contractname, bytes32[] calldata records) external view returns (bool[] memory);

    function getbytes32value(bytes32 contractname, bytes32 record) external view returns (bytes32);

    function getbytes32values(bytes32 contractname, bytes32[] calldata records) external view returns (bytes32[] memory);

    
    function deleteuintvalue(bytes32 contractname, bytes32 record) external;

    function deleteintvalue(bytes32 contractname, bytes32 record) external;

    function deleteaddressvalue(bytes32 contractname, bytes32 record) external;

    function deleteboolvalue(bytes32 contractname, bytes32 record) external;

    function deletebytes32value(bytes32 contractname, bytes32 record) external;

    function setuintvalue(
        bytes32 contractname,
        bytes32 record,
        uint value
    ) external;

    function setuintvalues(
        bytes32 contractname,
        bytes32[] calldata records,
        uint[] calldata values
    ) external;

    function setintvalue(
        bytes32 contractname,
        bytes32 record,
        int value
    ) external;

    function setintvalues(
        bytes32 contractname,
        bytes32[] calldata records,
        int[] calldata values
    ) external;

    function setaddressvalue(
        bytes32 contractname,
        bytes32 record,
        address value
    ) external;

    function setaddressvalues(
        bytes32 contractname,
        bytes32[] calldata records,
        address[] calldata values
    ) external;

    function setboolvalue(
        bytes32 contractname,
        bytes32 record,
        bool value
    ) external;

    function setboolvalues(
        bytes32 contractname,
        bytes32[] calldata records,
        bool[] calldata values
    ) external;

    function setbytes32value(
        bytes32 contractname,
        bytes32 record,
        bytes32 value
    ) external;

    function setbytes32values(
        bytes32 contractname,
        bytes32[] calldata records,
        bytes32[] calldata values
    ) external;
}
