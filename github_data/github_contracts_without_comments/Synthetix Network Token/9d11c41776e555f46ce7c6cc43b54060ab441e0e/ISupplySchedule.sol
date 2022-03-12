pragma solidity >=0.4.24;


interface isupplyschedule {
    
    function mintablesupply() external view returns (uint);

    function ismintable() external view returns (bool);

    
    function recordmintevent(uint supplyminted) external returns (bool);
}
