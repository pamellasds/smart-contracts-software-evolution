pragma solidity >=0.5.0;
pragma experimental abiencoderv2;

import ;

contract vatlike {
    struct ilk {
        uint256 art;   
        uint256 rate;  
    }
    function ilks(bytes32) public returns (ilk memory);
    function fold(bytes32,bytes32,int) public;
}

contract jug is dsnote {
    
    mapping (address => uint) public wards;
    function rely(address usr) public note auth { wards[usr] = 1; }
    function deny(address usr) public note auth { wards[usr] = 0; }
    modifier auth { require(wards[msg.sender] == 1); _; }

    
    struct ilk {
        uint256 tax;
        uint48  rho;
    }

    mapping (bytes32 => ilk) public ilks;
    vatlike                  public vat;
    bytes32                  public vow;
    uint256                  public repo;

    
    constructor(address vat_) public {
        wards[msg.sender] = 1;
        vat = vatlike(vat_);
    }

    
    function rpow(uint x, uint n, uint base) internal pure returns (uint z) {
      assembly {
        switch x case 0 {switch n case 0 {z := base} default {z := 0}}
        default {
          switch mod(n, 2) case 0 { z := base } default { z := x }
          let half := div(base, 2)  
          for { n := div(n, 2) } n { n := div(n,2) } {
            let xx := mul(x, x)
            if iszero(eq(div(xx, x), x)) { revert(0,0) }
            let xxround := add(xx, half)
            if lt(xxround, xx) { revert(0,0) }
            x := div(xxround, base)
            if mod(n,2) {
              let zx := mul(z, x)
              if and(iszero(iszero(x)), iszero(eq(div(zx, x), z))) { revert(0,0) }
              let zxround := add(zx, half)
              if lt(zxround, zx) { revert(0,0) }
              z := div(zxround, base)
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

    
    function init(bytes32 ilk) public note auth {
        ilk storage i = ilks[ilk];
        require(i.tax == 0);
        i.tax = one;
        i.rho = uint48(now);
    }
    function file(bytes32 ilk, bytes32 what, uint data) public note auth {
        ilk storage i = ilks[ilk];
        if (what == ) i.tax = data;
    }
    function file(bytes32 what, uint data) public note auth {
        if (what == ) repo = data;
    }
    function file(bytes32 what, bytes32 data) public note auth {
        if (what == ) vow = data;
    }

    
    function drip(bytes32 ilk) public note {
        require(now >= ilks[ilk].rho);
        vatlike.ilk memory i = vat.ilks(ilk);
        vat.fold(ilk, vow, diff(rmul(rpow(add(repo, ilks[ilk].tax), now  ilks[ilk].rho, one), i.rate), i.rate));
        ilks[ilk].rho = uint48(now);
    }
}
