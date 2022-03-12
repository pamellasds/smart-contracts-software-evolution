pragma solidity ^0.5.16;


interface iaddressresolver {
    function getaddress(bytes32 name) external view returns (address);

    function getsynth(bytes32 key) external view returns (address);

    function requireandgetaddress(bytes32 name, string calldata reason) external view returns (address);
}
