
pragma solidity 0.6.12;


interface iconverterupgrader {
    function upgrade(bytes32 _version) external;
    function upgrade(uint16 _version) external;
}
