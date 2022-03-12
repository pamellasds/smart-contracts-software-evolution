pragma solidity ^0.4.23;


interface authority {
    function executor() external view returns(address);
    function add(address _signer, address _endorsor, bytes32 _identity) external;
    function remove(address _signer) external;
    function get(address _signer) external view returns(bool listed, address endorsor, bytes32 identity, bool active);
    function first() external view returns(address);
    function next(address _signer) external view returns(address);
}