
pragma solidity 0.6.12;


interface ibancorxupgrader {
    function upgrade(uint16 _version, address[] memory _reporters) external;
}
