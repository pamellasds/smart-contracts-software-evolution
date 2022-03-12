













pragma solidity >=0.5.0;

import ;

contract vatlike {
    function move(address,address,uint) public;
    function flux(bytes32,address,address,uint) public;
}



contract flipper is dsnote {
    
    mapping (address => uint) public wards;
    function rely(address guy) public note auth { wards[guy] = 1; }
    function deny(address guy) public note auth { wards[guy] = 0; }
    modifier auth { require(wards[msg.sender] == 1); _; }

    
    struct bid {
        uint256 bid;
        uint256 lot;
        address guy;  
        uint48  tic;  
        uint48  end;
        address urn;
        address gal;
        uint256 tab;
    }

    mapping (uint => bid) public bids;

    vatlike public   vat;
    bytes32 public   ilk;

    uint256 constant one = 1.00e27;
    uint256 public   beg = 1.05e27;  
    uint48  public   ttl = 3 hours;  
    uint48  public   tau = 2 days;   
    uint256 public kicks = 0;

    
    event kick(
      uint256 id,
      uint256 lot,
      uint256 bid,
      uint256 tab,
      address indexed urn,
      address indexed gal
    );

    
    constructor(address vat_, bytes32 ilk_) public {
        vat = vatlike(vat_);
        ilk = ilk_;
        wards[msg.sender] = 1;
    }

    
    function add(uint48 x, uint48 y) internal pure returns (uint48 z) {
        require((z = x + y) >= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    
    function kick(address urn, address gal, uint tab, uint lot, uint bid)
        public note returns (uint id)
    {
        require(kicks < uint(1));
        id = ++kicks;

        bids[id].bid = bid;
        bids[id].lot = lot;
        bids[id].guy = msg.sender; 
        bids[id].end = add(uint48(now), tau);
        bids[id].urn = urn;
        bids[id].gal = gal;
        bids[id].tab = tab;

        vat.flux(ilk, msg.sender, address(this), lot);

        emit kick(id, lot, bid, tab, urn, gal);
    }
    function tick(uint id) public note {
        require(bids[id].end < now);
        require(bids[id].tic == 0);
        bids[id].end = add(uint48(now), tau);
    }
    function tend(uint id, uint lot, uint bid) public note {
        require(bids[id].guy != address(0));
        require(bids[id].tic > now || bids[id].tic == 0);
        require(bids[id].end > now);

        require(lot == bids[id].lot);
        require(bid <= bids[id].tab);
        require(bid >  bids[id].bid);
        require(mul(bid, one) >= mul(beg, bids[id].bid) || bid == bids[id].tab);

        vat.move(msg.sender, bids[id].guy, bids[id].bid);
        vat.move(msg.sender, bids[id].gal, bid  bids[id].bid);

        bids[id].guy = msg.sender;
        bids[id].bid = bid;
        bids[id].tic = add(uint48(now), ttl);
    }
    function dent(uint id, uint lot, uint bid) public note {
        require(bids[id].guy != address(0));
        require(bids[id].tic > now || bids[id].tic == 0);
        require(bids[id].end > now);

        require(bid == bids[id].bid);
        require(bid == bids[id].tab);
        require(lot < bids[id].lot);
        require(mul(beg, lot) <= mul(bids[id].lot, one));

        vat.move(msg.sender, bids[id].guy, bid);
        vat.flux(ilk, address(this), bids[id].urn, bids[id].lot  lot);

        bids[id].guy = msg.sender;
        bids[id].lot = lot;
        bids[id].tic = add(uint48(now), ttl);
    }
    function deal(uint id) public note {
        require(bids[id].tic != 0 && (bids[id].tic < now || bids[id].end < now));
        vat.flux(ilk, address(this), bids[id].guy, bids[id].lot);
        delete bids[id];
    }

    function yank(uint id) public note auth {
        require(bids[id].guy != address(0));
        require(bids[id].bid < bids[id].tab);
        vat.flux(ilk, address(this), msg.sender, bids[id].lot);
        vat.move(msg.sender, bids[id].guy, bids[id].bid);
        delete bids[id];
    }
}
