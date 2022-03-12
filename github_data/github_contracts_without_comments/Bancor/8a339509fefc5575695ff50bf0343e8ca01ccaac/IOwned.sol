
pragma solidity 0.6.12;


abstract contract iowned {
    
    function owner() external virtual view returns (address);

    function transferownership(address _newowner) public virtual;
    function acceptownership() public virtual;
}
