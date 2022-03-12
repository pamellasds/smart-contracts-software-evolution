













pragma solidity 0.5.11;

import ;

contract vatlike {
    function move(address,address,uint) external;
    function flux(bytes32,address,address,uint) external;
}



contract flipper is libnote {
    
    mapping (address => uint) public wards;
    function rely(address usr) external note auth { wards[usr] = 1; }
    function deny(address usr) external note auth { wards[usr] = 0; }
    modifier auth { require(wards[msg.sender] == 1); _; }

    
    struct bid {
        uint256 bid;
        uint256 lot;
        address guy;  
        uint48  tic;  
        uint48  end;
        address usr;
        address gal;
        uint256 tab;
    }

    mapping (uint => bid) public bids;

    vatlike public   vat;
    bytes32 public   ilk;

    uint256 constant one = 1.00e18;
    uint256 public   beg = 1.05e18;  
    uint48  public   ttl = 3 hours;  
    uint48  public   tau = 2 days;   
    uint256 public kicks = 0;

    
    event kick(
      uint256 id,
      uint256 lot,
      uint256 bid,
      uint256 tab,
      address indexed usr,
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

    
    function file(bytes32 what, uint data) external note auth {
        if (what == ) beg = data;
        else if (what == ) ttl = uint48(data);
        else if (what == ) tau = uint48(data);
        else revert();
    }

    
    function kick(address usr, address gal, uint tab, uint lot, uint bid)
        public auth returns (uint id)
    {
        require(kicks < uint(1));
        id = ++kicks;

        bids[id].bid = bid;
        bids[id].lot = lot;
        bids[id].guy = msg.sender; 
        bids[id].end = add(uint48(now), tau);
        bids[id].usr = usr;
        bids[id].gal = gal;
        bids[id].tab = tab;

        vat.flux(ilk, msg.sender, address(this), lot);

        emit kick(id, lot, bid, tab, usr, gal);
    }
    function tick(uint id) external note {
        require(bids[id].end < now);
        require(bids[id].tic == 0);
        bids[id].end = add(uint48(now), tau);
    }
    function tend(uint id, uint lot, uint bid) external note {
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
    function dent(uint id, uint lot, uint bid) external note {
        require(bids[id].guy != address(0));
        require(bids[id].tic > now || bids[id].tic == 0);
        require(bids[id].end > now);

        require(bid == bids[id].bid);
        require(bid == bids[id].tab);
        require(lot < bids[id].lot);
        require(mul(beg, lot) <= mul(bids[id].lot, one));

        vat.move(msg.sender, bids[id].guy, bid);
        vat.flux(ilk, address(this), bids[id].usr, bids[id].lot  lot);

        bids[id].guy = msg.sender;
        bids[id].lot = lot;
        bids[id].tic = add(uint48(now), ttl);
    }
    function deal(uint id) external note {
        require(bids[id].tic != 0 && (bids[id].tic < now || bids[id].end < now));
        vat.flux(ilk, address(this), bids[id].guy, bids[id].lot);
        delete bids[id];
    }

    function yank(uint id) external note auth {
        require(bids[id].guy != address(0));
        require(bids[id].bid < bids[id].tab);
        vat.flux(ilk, address(this), msg.sender, bids[id].lot);
        vat.move(msg.sender, bids[id].guy, bids[id].bid);
        delete bids[id];
    }
}
