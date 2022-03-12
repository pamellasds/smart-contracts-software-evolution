pragma solidity >=0.4.24;


interface irewardsdistribution {
    
    function distributerewards(uint amount) external returns (bool);
}
