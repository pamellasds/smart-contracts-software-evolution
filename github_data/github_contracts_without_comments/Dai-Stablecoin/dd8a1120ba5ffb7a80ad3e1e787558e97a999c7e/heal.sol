













pragma solidity ^0.4.24;

contract fusspot {
    function kick(address gal, uint lot, uint bid) public returns (uint);
}

contract dailike {
    function dai (bytes32) public view returns (int);
    function heal(bytes32,bytes32,int) public;
}

contract vow {
    address vat;
    address cow;  
    address row;  

    function era() public view returns (uint48) { return uint48(now); }
    modifier auth { _; }  

    mapping (uint48 => uint256) public sin; 
    uint256 public sin;   
    uint256 public woe;   
    uint256 public ash;   

    uint256 public wait;  
    uint256 public lump;  
    uint256 public pad;   

    uint256 constant one = 10 ** 27;

    function add(uint x, uint y) internal pure returns (uint z) {
        z = x + y;
        require(z >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        z = x  y;
        require(z <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    function awe() public view returns (uint) { return add(add(sin, woe), ash); }
    function joy() public view returns (uint) { return uint(dailike(vat).dai(bytes32(address(this)))) / one; }

    function file(bytes32 what, uint risk) public auth {
        if (what == ) lump = risk;
        if (what == )  pad  = risk;
    }
    function file(bytes32 what, address addr) public auth {
        if (what == ) cow = addr;
        if (what == ) row = addr;
        if (what == )  vat = addr;
    }

    function heal(uint wad) public {
        require(wad <= joy() && wad <= woe);
        woe = sub(woe, wad);
        require(int(mul(wad, one)) >= 0);
        dailike(vat).heal(bytes32(address(this)), bytes32(address(this)), int(mul(wad, one)));
    }
    function kiss(uint wad) public {
        require(wad <= ash && wad <= joy());
        ash = sub(ash, wad);
        require(int(mul(wad, one)) >= 0);
        dailike(vat).heal(bytes32(address(this)), bytes32(address(this)), int(mul(wad, one)));
    }

    function fess(uint tab) public auth {
        sin[era()] = add(sin[era()], tab);
        sin = add(sin, tab);
    }
    function flog(uint48 era_) public {
        sin = sub(sin, sin[era_]);
        woe = add(woe, sin[era_]);
        sin[era_] = 0;
    }

    function flop() public returns (uint) {
        require(woe >= lump);
        require(joy() == 0);
        woe = sub(woe, lump);
        ash = add(ash, lump);
        return fusspot(row).kick(this, uint(1), lump);
    }
    function flap() public returns (uint) {
        require(joy() >= add(add(awe(), lump), pad));
        require(woe == 0);
        return fusspot(cow).kick(this, lump, 0);
    }
}
