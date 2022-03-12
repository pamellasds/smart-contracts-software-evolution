













pragma solidity >=0.5.0;
pragma experimental abiencoderv2;

import ;

contract vatlike {
    struct ilk {
        uint256 take;  
        uint256 rate;  
        uint256 ink;   
        uint256 art;   
    }
    struct urn {
        uint256 ink;   
        uint256 art;   
    }
    function debt() public view returns (uint);
    function ilks(bytes32) public view returns (ilk memory);
    function urns(bytes32,bytes32) public view returns (urn memory);
    function tune(bytes32,bytes32,bytes32,bytes32,int,int) public;
}

contract pit is dsnote {
    
    mapping (address => uint) public wards;
    function rely(address guy) public note auth { wards[guy] = 1; }
    function deny(address guy) public note auth { wards[guy] = 0; }
    modifier auth { require(wards[msg.sender] == 1); _; }

    
    struct ilk {
        uint256  spot;  
        uint256  line;  
    }
    mapping (bytes32 => ilk) public ilks;

    uint256 public live;  
    uint256 public line;  
    vatlike public  vat;  

    
    event frob(
      bytes32 indexed ilk,
      bytes32 indexed urn,
      int256  dink,
      int256  dart
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

    
    function file(bytes32 what, uint data) public note auth {
        if (what == ) line = data;
    }
    function file(bytes32 ilk, bytes32 what, uint data) public note auth {
        if (what == ) ilks[ilk].spot = data;
        if (what == ) ilks[ilk].line = data;
    }

    
    function frob(bytes32 ilk, bytes32 urn, bytes32 gem, bytes32 dai, int dink, int dart) public {
        vatlike(vat).tune(ilk, urn, gem, dai, dink, dart);

        vatlike.ilk memory i = vat.ilks(ilk);
        vatlike.urn memory u = vat.urns(ilk, urn);

        bool calm = mul(i.art, i.rate) <= mul(ilks[ilk].line, one) &&
                            vat.debt() <= mul(line, one);
        bool safe = mul(u.ink, ilks[ilk].spot) >= mul(u.art, i.rate);

        require((calm || dart <= 0) && (dart <= 0 && dink >= 0 || safe));

        require(msg.sender == address(bytes20(urn)) || dart <= 0 && dink >= 0);
        require(msg.sender == address(bytes20(gem)) || dink < 0);
        require(msg.sender == address(bytes20(dai)) || dart > 0);

        require(i.rate != 0);
        require(live == 1);

        emit frob(ilk, urn, dink, dart);
    }
}
