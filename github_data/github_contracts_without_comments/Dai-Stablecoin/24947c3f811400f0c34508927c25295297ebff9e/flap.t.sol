pragma solidity >=0.5.0;

import ;
import {dstoken} from ;
import ;
import ;


contract hevm {
    function warp(uint256) public;
}

contract guy {
    flapper flap;
    constructor(flapper flap_) public {
        flap = flap_;
        vat(address(flap.vat())).hope(address(flap));
        dstoken(address(flap.gem())).approve(address(flap));
    }
    function tend(uint id, uint lot, uint bid) public {
        flap.tend(id, lot, bid);
    }
    function deal(uint id) public {
        flap.deal(id);
    }
    function try_tend(uint id, uint lot, uint bid)
        public returns (bool ok)
    {
        string memory sig = ;
        (ok,) = address(flap).call(abi.encodewithsignature(sig, id, lot, bid));
    }
    function try_deal(uint id)
        public returns (bool ok)
    {
        string memory sig = ;
        (ok,) = address(flap).call(abi.encodewithsignature(sig, id));
    }
    function try_tick(uint id)
        public returns (bool ok)
    {
        string memory sig = ;
        (ok,) = address(flap).call(abi.encodewithsignature(sig, id));
    }
}

contract flaptest is dstest {
    hevm hevm;

    flapper flap;
    vat     vat;
    dstoken gem;

    address ali;
    address bob;

    function setup() public {
        hevm = hevm(0x7109709ecfa91a80626ff3989d68f67f5b1dd12d);
        hevm.warp(604411200);

        vat = new vat();
        gem = new dstoken();

        flap = new flapper(address(vat), address(gem));

        ali = address(new guy(flap));
        bob = address(new guy(flap));

        vat.hope(address(flap));
        gem.approve(address(flap));

        vat.suck(address(this), address(this), 1000 ether);

        gem.mint(1000 ether);
        gem.setowner(address(flap));

        gem.push(ali, 200 ether);
        gem.push(bob, 200 ether);
    }
    function test_kick() public {
        asserteq(vat.dai(address(this)), 1000 ether);
        asserteq(vat.dai(address(flap)),    0 ether);
        flap.kick({ lot: 100 ether
                  , bid: 0
                  });
        asserteq(vat.dai(address(this)),  900 ether);
        asserteq(vat.dai(address(flap)),  100 ether);
    }
    function test_tend() public {
        uint id = flap.kick({ lot: 100 ether
                            , bid: 0
                            });
        
        asserteq(vat.dai(address(this)), 900 ether);

        guy(ali).tend(id, 100 ether, 1 ether);
        
        asserteq(gem.balanceof(ali), 199 ether);
        
        asserteq(gem.balanceof(address(flap)),  1 ether);

        guy(bob).tend(id, 100 ether, 2 ether);
        
        asserteq(gem.balanceof(bob), 198 ether);
        
        asserteq(gem.balanceof(ali), 200 ether);
        
        asserteq(gem.balanceof(address(flap)),   2 ether);

        hevm.warp(now + 5 weeks);
        guy(bob).deal(id);
        
        asserteq(vat.dai(address(flap)),  0 ether);
        asserteq(vat.dai(bob), 100 ether);
        
        asserteq(gem.balanceof(address(flap)),   0 ether);
    }
    function test_beg() public {
        uint id = flap.kick({ lot: 100 ether
                            , bid: 0
                            });
        asserttrue( guy(ali).try_tend(id, 100 ether, 1.00 ether));
        asserttrue(!guy(bob).try_tend(id, 100 ether, 1.01 ether));
        
        asserttrue(!guy(ali).try_tend(id, 100 ether, 1.01 ether));
        asserttrue( guy(bob).try_tend(id, 100 ether, 1.07 ether));
    }
    function test_tick() public {
        
        uint id = flap.kick({ lot: 100 ether
                            , bid: 0
                            });
        
        asserttrue(!guy(ali).try_tick(id));
        
        hevm.warp(now + 2 weeks);
        
        asserttrue(!guy(ali).try_tend(id, 100 ether, 1 ether));
        asserttrue( guy(ali).try_tick(id));
        
        asserttrue( guy(ali).try_tend(id, 100 ether, 1 ether));
    }
}
