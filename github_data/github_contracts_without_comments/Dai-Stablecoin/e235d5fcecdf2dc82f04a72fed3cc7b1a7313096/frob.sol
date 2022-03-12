













pragma solidity ^0.4.24;

import ;

contract vatlike {
    function debt() public view returns (uint);
    function ilks(bytes32) public view returns (uint,uint,uint,uint);
    function urns(bytes32,bytes32) public view returns (uint,uint);
    function tune(bytes32,bytes32,bytes32,bytes32,int,int) public;
}

contract dripper {
    function drip(bytes32) public;
}

contract pit is dsnote {
    
    mapping (address => uint) public wards;
    function rely(address guy) public note auth { wards[guy] = 1;  }
    function deny(address guy) public note auth { wards[guy] = 0; }
    modifier auth { require(wards[msg.sender] == 1); _;  }

    
    struct ilk {
        uint256  spot;  
        uint256  line;  
    }
    mapping (bytes32 => ilk) public ilks;

    uint256 public live;  
    uint256 public line;  
    vatlike public  vat;  
    dripper public drip;  

    
    event frob(
      bytes32 indexed ilk,
      bytes32 indexed urn,
      uint256 ink,
      uint256 art,
      int256  dink,
      int256  dart,
      uint256 iart
    );

    
    constructor(address vat_) public {
        wards[msg.sender] = 1;
        vat = vatlike(vat_);
        live = 1;
    }

    
    uint256 constant one = 10 ** 27;

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    
    function file(bytes32 what, address data) public note auth {
        if (what == ) drip = dripper(data);
    }
    function file(bytes32 what, uint data) public note auth {
        if (what == ) line = data;
    }
    function file(bytes32 ilk, bytes32 what, uint data) public note auth {
        if (what == ) ilks[ilk].spot = data;
        if (what == ) ilks[ilk].line = data;
    }

    
    function frob(bytes32 ilk, int dink, int dart) public {
        drip.drip(ilk);
        vatlike(vat).tune(ilk, bytes32(msg.sender), bytes32(msg.sender),
                          bytes32(msg.sender), dink, dart);

        (uint take, uint rate, uint ink, uint art) = vat.ilks(ilk); take; ink;
        (uint ink,  uint art) = vat.urns(ilk, bytes32(msg.sender));
        bool calm = mul(art, rate) <= mul(ilks[ilk].line, one)
                    &&  vat.debt() <= mul(line, one);
        bool safe = mul(ink, ilks[ilk].spot) >= mul(art, rate);

        require(live == 1);
        require(rate != 0);
        require((calm || dart <= 0) && (dart <= 0 && dink >= 0 || safe));

        emit frob(ilk, bytes32(msg.sender), ink, art, dink, dart, art);
    }
}
