













pragma solidity =0.5.11;

import ;



contract vatlike {
    function move(address,address,uint256) external;
    function suck(address,address,uint256) external;
}

contract pot is dsnote {
    
    mapping (address => uint) public wards;
    function rely(address guy) external note auth { wards[guy] = 1; }
    function deny(address guy) external note auth { wards[guy] = 0; }
    modifier auth { require(wards[msg.sender] == 1); _; }

    
    mapping (address => uint256) public pie;  

    uint256 public pie;  
    uint256 public dsr;  
    uint256 public chi;  

    vatlike public vat;  
    address public vow;  
    uint256 public rho;  

    uint256 public live;  

    
    constructor(address vat_) public {
        wards[msg.sender] = 1;
        vat = vatlike(vat_);
        dsr = one;
        chi = one;
        rho = now;
        live = 1;
    }

    
    uint256 constant one = 10 ** 27;
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

    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = mul(x, y) / one;
    }

    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x  y) <= x);
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    
    function file(bytes32 what, uint256 data) external note auth {
        require(live == 1);
        require(now == rho);
        if (what == ) dsr = data;
        else revert();
    }

    function file(bytes32 what, address addr) external note auth {
        if (what == ) vow = addr;
        else revert();
    }

    function cage() external note auth {
        live = 0;
        dsr = one;
    }

    
    function drip() external note {
        require(now >= rho);
        uint chi_ = sub(rmul(rpow(dsr, now  rho, one), chi), chi);
        chi = add(chi, chi_);
        rho = now;
        vat.suck(address(vow), address(this), mul(pie, chi_));
    }

    
    function join(uint wad) external note {
        require(now == rho);
        pie[msg.sender] = add(pie[msg.sender], wad);
        pie             = add(pie,             wad);
        vat.move(msg.sender, address(this), mul(chi, wad));
    }

    function exit(uint wad) external note {
        pie[msg.sender] = sub(pie[msg.sender], wad);
        pie             = sub(pie,             wad);
        vat.move(address(this), msg.sender, mul(chi, wad));
    }
}
