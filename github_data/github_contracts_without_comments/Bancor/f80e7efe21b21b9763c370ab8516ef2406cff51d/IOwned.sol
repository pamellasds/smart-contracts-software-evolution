
pragma solidity 0.6.12;


interface iowned {
    
    function owner() external view returns (address);

    function transferownership(address _newowner) external;
    function acceptownership() external;
}
