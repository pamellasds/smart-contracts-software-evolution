pragma solidity ^0.4.23;






interface extension {
    
    function blake2b256(bytes _value) external view returns(bytes32);

    
    function blockid(uint num) external view returns(bytes32);
    function blocktotalscore(uint num) external view returns(uint64);
    function blocktime(uint num) external view returns(uint);
    function blocksigner(uint num) external view returns(address);

    
    function totalsupply() external view returns(uint256);

    
    function txprovedwork() external view returns(uint256);
    function txid() external view returns(bytes32);
    function txblockref() external view returns(bytes8);
    function txexpiration() external view returns(uint);
}