pragma solidity 0.4.25;


interface isynth {
    function burn(address account, uint amount) external;

    function issue(address account, uint amount) external;

    function transfer(address to, uint value) external returns (bool);

    function transferfrom(address from, address to, uint value) external returns (bool);

    function transferfromandsettle(address from, address to, uint value) external returns (bool);

    function balanceof(address owner) external view returns (uint);
}
