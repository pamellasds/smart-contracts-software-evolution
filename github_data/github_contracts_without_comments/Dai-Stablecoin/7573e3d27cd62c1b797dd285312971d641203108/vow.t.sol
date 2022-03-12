pragma solidity >=0.5.0;

import ;

import {flopper as flop} from ;
import {flapper as flap} from ;
import {testvat  as vat} from ;
import {vow}     from ;

contract hevm {
    function warp(uint256) public;
}

contract gem {
    mapping (address => uint256) public balanceof;
    function mint(address usr, uint wad) public {
        balanceof[usr] += wad;
    }
}

contract vowtest is dstest {
    hevm hevm;

    vat  vat;
    vow  vow;
    flop flop;
    flap flap;
    gem  gov;

    function setup() public {
        hevm = hevm(0x7109709ecfa91a80626ff3989d68f67f5b1dd12d);
        hevm.warp(0);

        vat = new vat();
        vow = new vow();
        vat.rely(address(vow));
        gov  = new gem();

        flop = new flop(address(vat), address(gov));
        flap = new flap(address(vat), address(gov));
        vat.hope(address(flop));
        vat.rely(address(flop));
        vat.rely(address(flap));
        flop.rely(address(vow));

        vow.file(,  address(vat));
        vow.file(, address(flop));
        vow.file(, address(flap));
        vow.file(, uint256(100 ether));
        vow.file(, uint256(100 ether));
    }

    function try_flog(uint48 era) internal returns (bool ok) {
        string memory sig = ;
        (ok,) = address(vow).call(abi.encodewithsignature(sig, era));
    }
    function try_flop() internal returns (bool ok) {
        string memory sig = ;
        (ok,) = address(vow).call(abi.encodewithsignature(sig));
    }
    function try_flap() internal returns (bool ok) {
        string memory sig = ;
        (ok,) = address(vow).call(abi.encodewithsignature(sig));
    }
    function try_dent(uint id, uint lot, uint bid) internal returns (bool ok) {
        string memory sig = ;
        (ok,) = address(flop).call(abi.encodewithsignature(sig, id, lot, bid));
    }

    uint256 constant one = 10 ** 27;
    function suck(address who, uint wad) internal {
        vow.fess(wad);
        vat.init();
        vat.heal(bytes32(bytes20(address(vow))), bytes32(bytes20(who)), int(wad * one));
    }
    function flog(uint wad) internal {
        suck(address(0), wad);  
        vow.flog(uint48(now));
    }

    function test_flog_wait() public {
        asserteq(vow.wait(), 0);
        vow.file(, uint(100 seconds));
        asserteq(vow.wait(), 100 seconds);

        uint48 tic = uint48(now);
        vow.fess(100 ether);
        asserttrue(!try_flog(tic) );
        hevm.warp(tic + uint48(100 seconds));
        asserttrue( try_flog(tic) );
    }

    function test_no_reflop() public {
        flog(100 ether);
        asserttrue( try_flop() );
        asserttrue(!try_flop() );
    }

    function test_no_flop_pending_joy() public {
        flog(200 ether);

        vat.mint(address(vow), 100 ether);
        asserttrue(!try_flop() );

        vow.heal(100 ether);
        asserttrue( try_flop() );
    }

    function test_flap() public {
        vat.mint(address(vow), 100 ether);
        asserttrue( try_flap() );
    }

    function test_no_flap_pending_sin() public {
        vow.file(, uint256(0 ether));
        flog(100 ether);

        vat.mint(address(vow), 50 ether);
        asserttrue(!try_flap() );
    }
    function test_no_flap_nonzero_woe() public {
        vow.file(, uint256(0 ether));
        flog(100 ether);
        vat.mint(address(vow), 50 ether);
        asserttrue(!try_flap() );
    }
    function test_no_flap_pending_flop() public {
        flog(100 ether);
        vow.flop();

        vat.mint(address(vow), 100 ether);

        asserttrue(!try_flap() );
    }
    function test_no_flap_pending_kiss() public {
        flog(100 ether);
        uint id = vow.flop();

        vat.mint(address(this), 100 ether);
        flop.dent(id, 0 ether, 100 ether);

        asserttrue(!try_flap() );
    }

    function test_no_surplus_after_good_flop() public {
        flog(100 ether);
        uint id = vow.flop();
        vat.mint(address(this), 100 ether);

        flop.dent(id, 0 ether, 100 ether);  

        asserttrue(!try_flap() );
    }

    function test_multiple_flop_dents() public {
        flog(100 ether);
        uint id = vow.flop();

        vat.mint(address(this), 100 ether);
        asserttrue(try_dent(id, 2 ether,  100 ether));

        vat.mint(address(this), 100 ether);
        asserttrue(try_dent(id, 1 ether,  100 ether));
    }
}
