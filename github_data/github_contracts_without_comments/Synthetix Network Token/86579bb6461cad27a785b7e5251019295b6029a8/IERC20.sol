pragma solidity >=0.4.24;


interface ierc20 {
    
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    
    function totalsupply() external view returns (uint);

    function balanceof(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);

    
    function transfer(address to, uint value) external returns (bool);

    function approve(address spender, uint value) external returns (bool);

    function transferfrom(
        address from,
        address to,
        uint value
    ) external returns (bool);

    
    event transfer(address indexed from, address indexed to, uint value);

    event approval(address indexed owner, address indexed spender, uint value);
}
