pragma solidity ^0.5.16;


interface isynth {
    
    function currencykey() external view returns (bytes32);

    
    function burn(address account, uint amount) external;

    function issue(address account, uint amount) external;

    function transferandsettle(address to, uint value) external returns (bool);

    function transferfromandsettle(
        address from,
        address to,
        uint value
    ) external returns (bool);
}
