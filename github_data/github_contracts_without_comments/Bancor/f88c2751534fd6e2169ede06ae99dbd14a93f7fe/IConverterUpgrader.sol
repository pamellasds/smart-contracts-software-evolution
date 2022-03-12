
pragma solidity 0.6.12;


abstract contract iconverterupgrader {
    function upgrade(bytes32 _version) public virtual;
    function upgrade(uint16 _version) public virtual;
}
