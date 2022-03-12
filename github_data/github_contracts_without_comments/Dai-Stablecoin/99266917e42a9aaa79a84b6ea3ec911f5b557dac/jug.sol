pragma solidity ^0.5.12;

import ;

contract vatlike {
    function ilks(bytes32) external returns (
        uint256 art,   
        uint256 rate   
    );
    function fold(bytes32,address,int) external;
}

contract jug is libnote {
    
    mapping (address => uint) public wards;
    function rely(address usr) external note auth { wards[usr] = 1; }
    function deny(address usr) external note auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, );
        _;
    }

    
    struct ilk {
        uint256 duty;
        uint256  rho;
    }

    mapping (bytes32 => ilk) public ilks;
    vatlike                  public vat;
    address                  public vow;
    uint256                  public base;

    
    constructor(address vat_) public {
        wards[msg.sender] = 1;
        vat = vatlike(vat_);
    }

    
    function rpow(uint x, uint n, uint b) internal pure returns (uint z) {
      assembly {
        switch x case 0 {switch n case 0 {z := b} default {z := 0}}
        default {
          switch mod(n, 2) case 0 { z := b } default { z := x }
          let half := div(b, 2)  
          for { n := div(n, 2) } n { n := div(n,2) } {
            let xx := mul(x, x)
            if iszero(eq(div(xx, x), x)) { revert(0,0) }
            let xxround := add(xx, half)
            if lt(xxround, xx) { revert(0,0) }
            x := div(xxround, b)
            if mod(n,2) {
              let zx := mul(z, x)
              if and(iszero(iszero(x)), iszero(eq(div(zx, x), z))) { revert(0,0) }
              let zxround := add(zx, half)
              if lt(zxround, zx) { revert(0,0) }
              z := div(zxround, b)
            }
          }
        }
      }
    }
    uint256 constant one = 10 ** 27;
    function add(uint x, uint y) internal pure returns (uint z) {
        z = x + y;
        require(z >= x);
    }
    function diff(uint x, uint y) internal pure returns (int z) {
        z = int(x)  int(y);
        require(int(x) >= 0 && int(y) >= 0);
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = x * y;
        require(y == 0 || z / y == x);
        z = z / one;
    }

    
    function init(bytes32 ilk) external note auth {
        ilk storage i = ilks[ilk];
        require(i.duty == 0, );
        i.duty = one;
        i.rho  = now;
    }
    function file(bytes32 ilk, bytes32 what, uint data) external note auth {
        require(now == ilks[ilk].rho, );
        if (what == ) ilks[ilk].duty = data;
        else revert();
    }
    function file(bytes32 what, uint data) external note auth {
        if (what == ) base = data;
        else revert();
    }
    function file(bytes32 what, address data) external note auth {
        if (what == ) vow = data;
        else revert();
    }

    
    function drip(bytes32 ilk) external note returns (uint rate) {
        require(now >= ilks[ilk].rho, );
        (, uint prev) = vat.ilks(ilk);
        rate = rmul(rpow(add(base, ilks[ilk].duty), now  ilks[ilk].rho, one), prev);
        vat.fold(ilk, vow, diff(rate, prev));
        ilks[ilk].rho = now;
    }
}
