pragma solidity >=0.4.24;


interface irewardsdistribution {
    
    struct distributiondata {
        address destination;
        uint amount;
    }

    
    function authority() external view returns (address);

    function distributions(uint index) external view returns (address destination, uint amount); 

    function distributionslength() external view returns (uint);

    
    function distributerewards(uint amount) external returns (bool);
}
