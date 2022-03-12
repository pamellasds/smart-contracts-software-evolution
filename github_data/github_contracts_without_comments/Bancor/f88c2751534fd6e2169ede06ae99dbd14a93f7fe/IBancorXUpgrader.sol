
pragma solidity 0.6.12;


abstract contract ibancorxupgrader {
    function upgrade(uint16 _version, address[] memory _reporters) public virtual;
}
