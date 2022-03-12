
pragma solidity 0.6.12;


interface iwhitelist {
    function iswhitelisted(address _address) external view returns (bool);
}
