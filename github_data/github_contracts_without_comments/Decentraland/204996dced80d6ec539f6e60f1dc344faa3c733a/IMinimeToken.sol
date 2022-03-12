pragma solidity ^0.4.24;


interface iminimetoken {




    
    
    
    
    function generatetokens(address _owner, uint _amount) external returns (bool);


    
    
    
    
    function destroytokens(address _owner, uint _amount) external returns (bool);

    
    
    function balanceof(address _owner) external view returns (uint256 balance);

    event transfer(address indexed _from, address indexed _to, uint256 _amount);
}