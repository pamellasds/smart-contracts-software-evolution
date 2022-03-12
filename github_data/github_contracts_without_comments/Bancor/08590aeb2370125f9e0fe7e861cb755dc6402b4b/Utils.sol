pragma solidity 0.4.26;


contract utils {
    
    constructor() public {
    }

    
    modifier greaterthanzero(uint256 _amount) {
        require(_amount > 0);
        _;
    }

    
    modifier validaddress(address _address) {
        require(_address != address(0));
        _;
    }

    
    modifier notthis(address _address) {
        require(_address != address(this));
        _;
    }

}
