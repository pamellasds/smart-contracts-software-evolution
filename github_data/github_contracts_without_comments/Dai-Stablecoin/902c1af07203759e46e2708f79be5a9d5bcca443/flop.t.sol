pragma solidity >=0.5.12;

import {dstest}  from ;
import {dstoken} from ;
import ;
import ;


interface hevm {
    function warp(uint256) external;
}

contract guy {
    flopper flop;
    constructor(flopper flop_) public {
        flop = flop_;
        vat(address(flop.vat())).hope(address(flop));
        dstoken(address(flop.gem())).approve(address(flop));
    }
    function dent(uint id, uint lot, uint bid) public {
        flop.dent(id, lot, bid);
    }
    function deal(uint id) public {
        flop.deal(id);
    }
    function try_dent(uint id, uint lot, uint bid)
        public returns (bool ok)
    {
        string memory sig = ;
        (ok,) = address(flop).call(abi.encodewithsignature(sig, id, lot, bid));
    }
    function try_deal(uint id)
        public returns (bool ok)
    {
        string memory sig = ;
        (ok,) = address(flop).call(abi.encodewithsignature(sig, id));
    }
    function try_tick(uint id)
        public returns (bool ok)
    {
        string memory sig = ;
        (ok,) = address(flop).call(abi.encodewithsignature(sig, id));
    }
}

contract gal {
    uint public ash;
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x  y) <= x);
    }
    function kick(flopper flop, uint lot, uint bid) external returns (uint) {
        ash += bid;
        return flop.kick(address(this), lot, bid);
    }
    function kiss(uint rad) external {
        ash = sub(ash, rad);
    }
    function cage(flopper flop) external {
        flop.cage();
    }
}

contract vatish is dstoken() {
    uint constant one = 10 ** 27;
    function hope(address usr) public {
         approve(usr);
    }
    function dai(address usr) public view returns (uint) {
         return balanceof(usr);
    }
}

contract floptest is dstest {
    hevm hevm;

    flopper flop;
    vat     vat;
    dstoken gem;

    address ali;
    address bob;
    address gal;

    function kiss(uint) public pure { }  

    function setup() public {
        hevm = hevm(0x7109709ecfa91a80626ff3989d68f67f5b1dd12d);
        hevm.warp(604411200);

        vat = new vat();
        gem = new dstoken();

        flop = new flopper(address(vat), address(gem));

        ali = address(new guy(flop));
        bob = address(new guy(flop));
        gal = address(new gal());

        flop.rely(gal);
        flop.deny(address(this));

        vat.hope(address(flop));
        vat.rely(address(flop));
        gem.approve(address(flop));

        vat.suck(address(this), address(this), 1000 ether);

        vat.move(address(this), ali, 200 ether);
        vat.move(address(this), bob, 200 ether);
    }

    function test_kick() public {
        asserteq(vat.dai(gal), 0);
        asserteq(gem.balanceof(gal), 0 ether);
        uint id = gal(gal).kick(flop,  200 ether,  5000 ether);
        
        asserteq(vat.dai(gal), 0);
        asserteq(gem.balanceof(gal), 0 ether);
        
        asserteq(flop.kicks(), id);
        (uint256 bid, uint256 lot, address guy, uint48 tic, uint48 end) = flop.bids(id);
        asserteq(bid, 5000 ether);
        asserteq(lot, 200 ether);
        asserttrue(guy == gal);
        asserteq(uint256(tic), 0);
        asserteq(uint256(end), now + flop.tau());
    }

    function test_dent() public {
        uint id = gal(gal).kick(flop,  200 ether,  10 ether);

        guy(ali).dent(id, 100 ether, 10 ether);
        
        asserteq(vat.dai(ali), 190 ether);
        
        asserteq(vat.dai(gal),  10 ether);
        asserteq(gal(gal).ash(), 0 ether);

        guy(bob).dent(id, 80 ether, 10 ether);
        
        asserteq(vat.dai(bob), 190 ether);
        
        asserteq(vat.dai(ali), 200 ether);
        
        asserteq(vat.dai(gal), 10 ether);

        hevm.warp(now + 5 weeks);
        asserteq(gem.totalsupply(),  0 ether);
        gem.setowner(address(flop));
        guy(bob).deal(id);
        
        asserteq(gem.totalsupply(), 80 ether);
        
        asserteq(gem.balanceof(bob), 80 ether);
    }

    function test_dent_ash_less_than_bid() public {
        uint id = gal(gal).kick(flop,  200 ether,  10 ether);
        asserteq(vat.dai(gal),  0 ether);

        gal(gal).kiss(1 ether);
        asserteq(gal(gal).ash(), 9 ether);

        guy(ali).dent(id, 100 ether, 10 ether);
        
        asserteq(vat.dai(ali), 190 ether);
        
        asserteq(vat.dai(gal),   10 ether);
        asserteq(gal(gal).ash(), 0 ether);

        guy(bob).dent(id, 80 ether, 10 ether);
        
        asserteq(vat.dai(bob), 190 ether);
        
        asserteq(vat.dai(ali), 200 ether);
        
        asserteq(vat.dai(gal), 10 ether);

        hevm.warp(now + 5 weeks);
        asserteq(gem.totalsupply(),  0 ether);
        gem.setowner(address(flop));
        guy(bob).deal(id);
        
        asserteq(gem.totalsupply(), 80 ether);
        
        asserteq(gem.balanceof(bob), 80 ether);
    }

    function test_dent_same_bidder() public {
        uint id = gal(gal).kick(flop,  200 ether,  200 ether);

        guy(ali).dent(id, 100 ether, 200 ether);
        asserteq(vat.dai(ali), 0);
        guy(ali).dent(id, 50 ether, 200 ether);
    }

    function test_tick() public {
        
        uint id = gal(gal).kick(flop,  200 ether,  10 ether);
        
        asserttrue(!guy(ali).try_tick(id));
        
        hevm.warp(now + 2 weeks);
        
        asserttrue(!guy(ali).try_dent(id, 100 ether, 10 ether));
        asserttrue( guy(ali).try_tick(id));
        
        (, uint _lot,,,) = flop.bids(id);
        
        asserteq(_lot, 300 ether);
        asserttrue( guy(ali).try_dent(id, 100 ether, 10 ether));
    }

    function test_no_deal_after_end() public {
        
        
        uint id = gal(gal).kick(flop,  200 ether,  10 ether);
        asserttrue(!guy(ali).try_deal(id));
        hevm.warp(now + 2 weeks);
        asserttrue(!guy(ali).try_deal(id));
        asserttrue( guy(ali).try_tick(id));
        asserttrue(!guy(ali).try_deal(id));
    }

    function test_yank() public {
        
        
        
        uint id = gal(gal).kick(flop,  200 ether,  10 ether);

        
        asserteq(vat.dai(ali), 200 ether);
        asserteq(vat.dai(bob), 200 ether);
        asserteq(vat.dai(gal), 0);
        asserteq(vat.sin(gal), 0);

        guy(ali).dent(id, 100 ether, 10 ether);
        guy(bob).dent(id, 80 ether, 10 ether);

        
        asserteq(vat.dai(ali), 200 ether);  
        asserteq(vat.dai(bob), 190 ether);
        asserteq(vat.dai(gal),  10 ether);
        asserteq(vat.sin(address(this)), 1000 ether);

        gal(gal).cage(flop);
        flop.yank(id);

        
        asserteq(vat.dai(ali), 200 ether);
        asserteq(vat.dai(bob), 200 ether);  
        asserteq(vat.dai(gal),  10 ether);
        asserteq(vat.sin(gal),  10 ether);  
        (uint256 _bid, uint256 _lot, address _guy, uint48 _tic, uint48 _end) = flop.bids(id);
        asserteq(_bid, 0);
        asserteq(_lot, 0);
        asserteq(_guy, address(0));
        asserteq(uint256(_tic), 0);
        asserteq(uint256(_end), 0);
    }

    function test_yank_no_bids() public {
        
        
        
        uint id = gal(gal).kick(flop,  200 ether,  10 ether);

        
        asserteq(vat.dai(ali), 200 ether);
        asserteq(vat.dai(bob), 200 ether);
        asserteq(vat.dai(gal), 0);
        asserteq(vat.sin(gal), 0);

        gal(gal).cage(flop);
        flop.yank(id);

        
        asserteq(vat.dai(ali), 200 ether);
        asserteq(vat.dai(bob), 200 ether);
        asserteq(vat.dai(gal),  10 ether);
        asserteq(vat.sin(gal),  10 ether);  
        (uint256 _bid, uint256 _lot, address _guy, uint48 _tic, uint48 _end) = flop.bids(id);
        asserteq(_bid, 0);
        asserteq(_lot, 0);
        asserteq(_guy, address(0));
        asserteq(uint256(_tic), 0);
        asserteq(uint256(_end), 0);
    }
}
