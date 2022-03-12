pragma solidity ^0.4.8;

import ;
import ;
import ;

contract standard223tokenreceivertest {
    standard223tokenexample token;
    standard223tokenreceivermock receiver;

    function beforeeach() {
        token = new standard223tokenexample(100);
        receiver = new standard223tokenreceivermock();
    }

    function testfallbackiscalledontransfer() {
        token.transfer(receiver, 10);

        assert.equal(receiver.tokensender(), this, );
        assert.equal(receiver.sentvalue(), 10, );
    }

    function testcorrectfunctioniscalledontransfer() {
        bytes memory data = new bytes(4);
        token.transfer(receiver, 20, data);

        assert.istrue(receiver.calledfallback(), );
    }
}
