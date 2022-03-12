pragma solidity >=0.5.0;

import ;

import {flopper as flop} from ;
import {flapper as flap} from ;
import {testvat as  vat} from ;
import {vow}     from ;

contract hevm {
    function warp(uint256) public;
}

contract gem {
    mapping (address => uint256) public balanceof;
    function mint(address usr, uint rad) public {
        balanceof[usr] += rad;
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
        hevm.warp(604411200);

        vat = new vat();

        gov  = new gem();
        flop = new flop(address(vat), address(gov));
        flap = new flap(address(vat), address(gov));

        vow = new vow(address(vat), address(flap), address(flop));
        flap.rely(address(vow));
        flop.rely(address(vow));

        vow.file(, rad(100 ether));
        vow.file(, rad(100 ether));
        vow.file(, 200 ether);

        vat.hope(address(flop));
    }

    function try_flog(uint era) internal returns (bool ok) {
        string memory sig = ;
        (ok,) = address(vow).call(abi.encodewithsignature(sig, era));
    }
    function try_dent(uint id, uint lot, uint bid) internal returns (bool ok) {
        string memory sig = ;
        (ok,) = address(flop).call(abi.encodewithsignature(sig, id, lot, bid));
    }
    function try_call(address addr, bytes calldata data) external returns (bool) {
        bytes memory _data = data;
        assembly {
            let ok := call(gas, addr, 0, add(_data, 0x20), mload(_data), 0, 0)
            let free := mload(0x40)
            mstore(free, ok)
            mstore(0x40, add(free, 32))
            revert(free, 32)
        }
    }
    function can_flap() public returns (bool) {
        string memory sig = ;
        bytes memory data = abi.encodewithsignature(sig);

        bytes memory can_call = abi.encodewithsignature(, vow, data);
        (bool ok, bytes memory success) = address(this).call(can_call);

        ok = abi.decode(success, (bool));
        if (ok) return true;
    }
    function can_flop() public returns (bool) {
        string memory sig = ;
        bytes memory data = abi.encodewithsignature(sig);

        bytes memory can_call = abi.encodewithsignature(, vow, data);
        (bool ok, bytes memory success) = address(this).call(can_call);

        ok = abi.decode(success, (bool));
        if (ok) return true;
    }

    uint constant one = 10 ** 27;
    function rad(uint wad) internal pure returns (uint) {
        return wad * one;
    }

    function suck(address who, uint wad) internal {
        vow.fess(rad(wad));
        vat.init();
        vat.suck(address(vow), who, rad(wad));
    }
    function flog(uint wad) internal {
        suck(address(0), wad);  
        vow.flog(now);
    }
    function heal(uint wad) internal {
        vow.heal(rad(wad));
    }

    function test_flog_wait() public {
        asserteq(vow.wait(), 0);
        vow.file(, uint(100 seconds));
        asserteq(vow.wait(), 100 seconds);

        uint tic = now;
        vow.fess(100 ether);
        asserttrue(!try_flog(tic) );
        hevm.warp(now + tic + 100 seconds);
        asserttrue( try_flog(tic) );
    }

    function test_no_reflop() public {
        flog(100 ether);
        asserttrue( can_flop() );
        vow.flop();
        asserttrue(!can_flop() );
    }

    function test_no_flop_pending_joy() public {
        flog(200 ether);

        vat.mint(address(vow), 100 ether);
        asserttrue(!can_flop() );

        heal(100 ether);
        asserttrue( can_flop() );
    }

    function test_flap() public {
        vat.mint(address(vow), 100 ether);
        asserttrue( can_flap() );
    }

    function test_no_flap_pending_sin() public {
        vow.file(, uint256(0 ether));
        flog(100 ether);

        vat.mint(address(vow), 50 ether);
        asserttrue(!can_flap() );
    }
    function test_no_flap_nonzero_woe() public {
        vow.file(, uint256(0 ether));
        flog(100 ether);
        vat.mint(address(vow), 50 ether);
        asserttrue(!can_flap() );
    }
    function test_no_flap_pending_flop() public {
        flog(100 ether);
        vow.flop();

        vat.mint(address(vow), 100 ether);

        asserttrue(!can_flap() );
    }
    function test_no_flap_pending_heal() public {
        flog(100 ether);
        uint id = vow.flop();

        vat.mint(address(this), 100 ether);
        flop.dent(id, 0 ether, rad(100 ether));

        asserttrue(!can_flap() );
    }

    function test_no_surplus_after_good_flop() public {
        flog(100 ether);
        uint id = vow.flop();
        vat.mint(address(this), 100 ether);

        flop.dent(id, 0 ether, rad(100 ether));  

        asserttrue(!can_flap() );
    }

    function test_multiple_flop_dents() public {
        flog(100 ether);
        uint id = vow.flop();

        vat.mint(address(this), 100 ether);
        asserttrue(try_dent(id, 2 ether,  rad(100 ether)));

        vat.mint(address(this), 100 ether);
        asserttrue(try_dent(id, 1 ether,  rad(100 ether)));
    }
}
