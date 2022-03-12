pragma solidity >=0.5.0;

import ;
import ;

import ;


contract hevm {
    function warp(uint256) public;
}

contract guy {
    flopper fuss;
    constructor(flopper fuss_) public {
        fuss = fuss_;
        dstoken(address(fuss.dai())).approve(address(fuss));
        dstoken(address(fuss.gem())).approve(address(fuss));
    }
    function dent(uint id, uint lot, uint bid) public {
        fuss.dent(id, lot, bid);
    }
    function deal(uint id) public {
        fuss.deal(id);
    }
    function try_dent(uint id, uint lot, uint bid)
        public returns (bool ok)
    {
        string memory sig = ;
        (ok,) = address(fuss).call(abi.encodewithsignature(sig, id, lot, bid));
    }
    function try_deal(uint id)
        public returns (bool ok)
    {
        string memory sig = ;
        (ok,) = address(fuss).call(abi.encodewithsignature(sig, id));
    }
}

contract gal {}

contract vatlike is dstoken() {
    uint constant one = 10 ** 27;
    function move(address src, address dst, uint rad) public {
        super.move(src, dst, rad);
    }
}

contract floptest is dstest {
    hevm hevm;

    flopper fuss;
    vatlike dai;
    dstoken gem;

    address ali;
    address bob;
    address gal;

    function kiss(uint) public pure { }  

    function setup() public {
        hevm = hevm(0x7109709ecfa91a80626ff3989d68f67f5b1dd12d);
        hevm.warp(1 hours);

        dai = new vatlike();
        gem = new dstoken();

        fuss = new flopper(address(dai), address(gem));

        ali = address(new guy(fuss));
        bob = address(new guy(fuss));
        gal = address(new gal());

        dai.approve(address(fuss));
        gem.approve(address(fuss));

        dai.mint(1000 ether);

        dai.push(ali, 200 ether);
        dai.push(bob, 200 ether);
    }
    function test_kick() public {
        asserteq(dai.balanceof(address(this)), 600 ether);
        asserteq(gem.balanceof(address(this)),   0 ether);
        fuss.kick({ lot: uint(1)   
                  , gal: gal
                  , bid: 0
                  });
        
        asserteq(dai.balanceof(address(this)), 600 ether);
        asserteq(gem.balanceof(address(this)),   0 ether);
    }
    function test_dent() public {
        uint id = fuss.kick({ lot: uint(1)   
                            , gal: gal
                            , bid: 10 ether
                            });

        guy(ali).dent(id, 100 ether, 10 ether);
        
        asserteq(dai.balanceof(ali), 190 ether);
        
        asserteq(dai.balanceof(gal),  10 ether);

        guy(bob).dent(id, 80 ether, 10 ether);
        
        asserteq(dai.balanceof(bob), 190 ether);
        
        asserteq(dai.balanceof(ali), 200 ether);
        
        asserteq(dai.balanceof(gal), 10 ether);

        hevm.warp(5 weeks);
        asserteq(gem.totalsupply(),  0 ether);
        gem.setowner(address(fuss));
        guy(bob).deal(id);
        
        asserteq(gem.totalsupply(), 80 ether);
        
        asserteq(gem.balanceof(bob), 80 ether);
    }
}
