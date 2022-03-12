
pragma solidity 0.6.12;


abstract contract iwhitelist {
    function iswhitelisted(address _address) public virtual view returns (bool);
}
